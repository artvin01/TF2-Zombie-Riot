#define GORE_ABDOMEN	  (1 << 0)
#define GORE_FOREARMLEFT  (1 << 1)
#define GORE_HANDRIGHT	(1 << 2)
#define GORE_FOREARMRIGHT (1 << 3)
#define GORE_HEAD		 (1 << 4)
#define GORE_HEADLEFT	 (1 << 5)
#define GORE_HEADRIGHT	(1 << 6)
#define GORE_UPARMLEFT	(1 << 7)
#define GORE_UPARMRIGHT   (1 << 8)
#define GORE_HANDLEFT	 (1 << 9)

enum //hitgroup_t
{
	HITGROUP_GENERIC,
	HITGROUP_HEAD,
	HITGROUP_CHEST,
	HITGROUP_STOMACH,
	HITGROUP_LEFTARM,
	HITGROUP_RIGHTARM,
	HITGROUP_LEFTLEG,
	HITGROUP_RIGHTLEG,
	
	NUM_HITGROUPS
};

enum struct NPCData
{
	int Ref;
	int LastHitId;
	int DamageBits;
	int LastHitWeaponRef;
	
	Handle IgniteTimer;
	int IgniteFor;
	int IgniteId;
	int IgniteRef;
}
static ArrayList NPCList;
static Handle SyncHud;
static char LastClassname[2049][64];
static float f_SpawnerCooldown[MAXENTITIES];

void NPC_PluginStart()
{
	NPCList = new ArrayList(sizeof(NPCData));
	SyncHud = CreateHudSynchronizer();
	
	LF_HookSpawn("", NPC_OnCreatePre, false);
	LF_HookSpawn("", NPC_OnCreatePost, true);
}

void NPC_RoundEnd()
{
	delete NPCList;
	NPCList = new ArrayList(sizeof(NPCData));
}

public Action LF_OnMakeNPC(char[] classname, int &entity)
{
	int index = StringToInt(classname);
	if(!index)
		index = GetIndexByPluginName(classname);
	
	entity = Npc_Create(index, -1, NULL_VECTOR, NULL_VECTOR);
	if(entity == -1)
		return Plugin_Continue;
	
	NPC_AddToArray(entity);
	return Plugin_Handled;
}

public Action NPC_OnCreatePre(char[] classname)
{
	if(!StrContains(classname, "npc_") && !StrEqual(classname, "npc_maker"))
	{
		strcopy(classname, 64, "base_boss");
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

public void NPC_OnCreatePost(const char[] classname, int entity)
{
	if(!StrContains(classname, "npc_") && !StrEqual(classname, "npc_maker"))
	{
		strcopy(LastClassname[entity], sizeof(LastClassname[]), classname);
		SDKHook(entity, SDKHook_SpawnPost, NPC_EntitySpawned);
	}
}

public void NPC_EntitySpawned(int entity)
{
	int index = GetIndexByPluginName(LastClassname[entity]);
	if(index)
	{
		float pos[3], ang[3];
		GetEntPropVector(entity, Prop_Data, "m_vecOrigin", pos);
		GetEntPropVector(entity, Prop_Data, "m_angRotation", ang);
		
		RemoveEntity(entity);
		
		int npc = Npc_Create(index, -1, pos, ang);
		if(npc != -1)
			NPC_AddToArray(npc);
	}
}

public void NPC_SpawnNext(bool force, bool panzer, bool panzer_warning)
{
	bool found;
	int entity = MaxClients+1;
	/*
	int limit = 10 + RoundToCeil(float(Waves_GetRound())/2.3);
	*/
	int limit = 0;
	int npc_current_count = 0;
	int amount_of_people;
	
	
	limit = 6 + RoundToCeil(float(Waves_GetRound())/2.65);
	
	amount_of_people = 0;
	for(int client=1; client<=MaxClients; client++)
	{
		if(IsClientInGame(client) && GetClientTeam(client)==2 && TeutonType[client] != TEUTON_WAITING)
		{
			amount_of_people += 1;
			limit += 1;
		}
	}
	
	if(!b_GameOnGoing) //no spawn if the round is over
	{
		return;
	}
	
	if(limit >= NPC_HARD_LIMIT)
		limit = NPC_HARD_LIMIT;
		
	if(!panzer)
	{
		while((entity=FindEntityByClassname(entity, "base_boss")) != -1)
		{
			if(GetEntProp(entity, Prop_Send, "m_iTeamNum") != view_as<int>(TFTeam_Red))
			{
				npc_current_count += 1;
				CClotBody npcstats = view_as<CClotBody>(entity);
				if(!npcstats.m_bThisNpcIsABoss)
				{
					if(Zombies_Currently_Still_Ongoing <= 3 && Zombies_Currently_Still_Ongoing > 0)
						SetEntProp(entity, Prop_Send, "m_bGlowEnabled", true);
					else
						SetEntProp(entity, Prop_Send, "m_bGlowEnabled", false);
				}
				found = true;
			}
		}
		//emercency stop. 
		if(npc_current_count >= limit)
		{
			return;
		}
	}
	
	bool npcInIt;
	float pos[3], ang[3];
	float gameTime = GetGameTime();
	ArrayList list = new ArrayList();
	int Active_Spawners = 0;
	while((entity=FindEntityByClassname(entity, "info_player_teamspawn")) != -1)
	{
		if(!GetEntProp(entity, Prop_Data, "m_bDisabled") && GetEntProp(entity, Prop_Data, "m_iTeamNum") != 2)
		{
			Active_Spawners += 1;
		}
	}
	float Active_Spawners_Calculate = 0.0;
	switch (Active_Spawners)
	{
		case 1:
		{
			Active_Spawners_Calculate = 1.9;
		}
		case 2:
		{
			Active_Spawners_Calculate = 1.65;
		}
		case 3:
		{
			Active_Spawners_Calculate = 1.55;
		}
		case 4:
		{
			Active_Spawners_Calculate = 1.4;
		}
		case 5:
		{
			Active_Spawners_Calculate = 1.2;
		}
		case 6:
		{
			Active_Spawners_Calculate = 0.7;
		}
		case 7:
		{
			Active_Spawners_Calculate = 0.6;
		}
		case 8:
		{
			Active_Spawners_Calculate = 0.3;
		}
	}
	
	while((entity=FindEntityByClassname(entity, "info_player_teamspawn")) != -1)
	{
		if(!GetEntProp(entity, Prop_Data, "m_bDisabled") && GetEntProp(entity, Prop_Data, "m_iTeamNum") != 2 && f_SpawnerCooldown[entity] < gameTime)
		{
			list.Push(entity);
		}
	}
	
	entity = list.Length;
	if(entity)
	{
		int health, isBoss;
		if(panzer)
		{
			entity = list.Get(GetRandomInt(0, entity-1));
			isBoss = false;
			int deathforcepowerup = 0;
			if(panzer_warning)
			{
				deathforcepowerup = 2;
				for(int panzer_warning_client=1; panzer_warning_client<=MaxClients; panzer_warning_client++)
				{
					if(IsClientInGame(panzer_warning_client) && GetClientTeam(panzer_warning_client)==2)
					{
						EmitSoundToClient(panzer_warning_client,"zombie_riot/panzer/siren.mp3", panzer_warning_client, SNDCHAN_AUTO, 90, _, 1.0);
						EmitSoundToClient(panzer_warning_client,"zombie_riot/panzer/siren.mp3", panzer_warning_client, SNDCHAN_AUTO, 90, _, 1.0);
					}
				}
				isBoss = true;
			}
			health = 80;
			
			health *= amount_of_people; //yep its high! will need tos cale with waves expoentially.
			
			float temp_float_hp = float(health);
			
			if(CurrentRound+1 < 30)
			{
				health = RoundToCeil(Pow(((temp_float_hp + float(CurrentRound+1)) * float(CurrentRound+1)),1.20));
				health /= 2;
			}
			else if(CurrentRound+1 < 45)
			{
				health = RoundToCeil(Pow(((temp_float_hp + float(CurrentRound+1)) * float(CurrentRound+1)),1.25));
				health /= 2;
			}
			else
			{
				health = RoundToCeil(Pow(((temp_float_hp + float(CurrentRound+1)) * float(CurrentRound+1)),1.35)); //Yes its way higher but i reduced overall hp of him
				health /= 2;
			}
			
			f_SpawnerCooldown[entity] = gameTime + 2.0;
			DataPack pack;
			CreateDataTimer(2.0, Timer_Delayed_PanzerSpawn, pack, TIMER_FLAG_NO_MAPCHANGE);
			pack.WriteCell(EntIndexToEntRef(entity));
			pack.WriteCell(isBoss);		
			pack.WriteCell(health);	
			pack.WriteCell(deathforcepowerup);			
		}
		else
		{
			char data[16];
			int index = Waves_GetNextEnemy(health, isBoss, data, sizeof(data));
			if(index)
			{
				entity = list.Get(GetRandomInt(0, entity-1));
				f_SpawnerCooldown[entity] = gameTime+(2.0 - Active_Spawners_Calculate);
				
				GetEntPropVector(entity, Prop_Data, "m_vecOrigin", pos);
				GetEntPropVector(entity, Prop_Data, "m_angRotation", ang);
				
				entity = Npc_Create(index, -1, pos, ang, data);
				if(entity != -1)
				{
					if(health)
					{
						SetEntProp(entity, Prop_Data, "m_iMaxHealth", health);
						SetEntProp(entity, Prop_Data, "m_iHealth", health);
					}
					
					CClotBody npcstats = view_as<CClotBody>(entity);
					if(isBoss)
					{
						SetEntProp(entity, Prop_Send, "m_bGlowEnabled", true);
						npcstats.m_bThisNpcIsABoss = true; //Set to true!
					}
					else
					{
						npcstats.m_bThisNpcIsABoss = false; //Set to true!
					}
					
					NPC_AddToArray(entity);
				}
			}
			else if(!found)
			{
				Waves_Progress();
			}
		}
	}
	else if(!npcInIt && !force)
	{
		NPC_SpawnNext(true, false, false);
	}
	delete list;
}

void NPC_AddToArray(int entity)
{
	NPCData npc;
	int index = NPCList.FindValue(EntIndexToEntRef(entity), NPCData::Ref);
	if(index == -1)
	{
		npc.Ref = EntIndexToEntRef(entity);
		NPCList.PushArray(npc);
	}
}

public Action Timer_Delayed_PanzerSpawn(Handle timer, DataPack pack)
{
	pack.Reset();
	int spawner_entity = EntRefToEntIndex(pack.ReadCell());
	bool isBoss = pack.ReadCell();
	int health = pack.ReadCell();
	int forcepowerup = pack.ReadCell();
	if(IsValidEdict(spawner_entity) && spawner_entity>MaxClients)
	{
		float pos[3], ang[3];
		float gameTime = GetGameTime();
		f_SpawnerCooldown[spawner_entity] = gameTime + 2.0;
			
		GetEntPropVector(spawner_entity, Prop_Data, "m_vecOrigin", pos);
		GetEntPropVector(spawner_entity, Prop_Data, "m_angRotation", ang);
		Zombies_Currently_Still_Ongoing += 1;
		int entity = Npc_Create(NAZI_PANZER, -1, pos, ang);
		if(entity != -1)
		{
			if(health)
			{
				SetEntProp(entity, Prop_Data, "m_iMaxHealth", health);
				SetEntProp(entity, Prop_Data, "m_iHealth", health);
			}
			
			CClotBody npcstats = view_as<CClotBody>(entity);
			if(isBoss)
			{
				SetEntProp(entity, Prop_Send, "m_bGlowEnabled", true);
				npcstats.m_bThisNpcIsABoss = true; //Set to true!
			}
			else
			{
				npcstats.m_bThisNpcIsABoss = false; //Set to true!
			}
			
			b_NpcForcepowerupspawn[entity] = forcepowerup;
			NPC_AddToArray(entity);
		}
	}
	return Plugin_Handled;
}

void NPC_Ignite(int entity, int client, float duration, int weapon)
{
	int index = NPCList.FindValue(EntIndexToEntRef(entity), NPCData::Ref);
	if(index != -1)
	{
		NPCData npc;
		NPCList.GetArray(index, npc);
		
		npc.IgniteFor += RoundToCeil(duration*2.0);
		if(npc.IgniteFor > 20)
			npc.IgniteFor = 20;
		
		if(!npc.IgniteTimer)
			npc.IgniteTimer = CreateTimer(0.5, NPC_TimerIgnite, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		
		npc.IgniteId = GetClientUserId(client);
		npc.IgniteRef = EntIndexToEntRef(weapon);
		NPCList.SetArray(index, npc);
	}
}

/*
int NPC_Extinguish(int entity)
{
	int index = NPCList.FindValue(EntIndexToEntRef(entity), NPCData::Ref);
	if(index != -1)
	{
		NPCData npc;
		NPCList.GetArray(index, npc);
		if(npc.IgniteFor && npc.IgniteTimer)
		{
			int ticks = npc.IgniteFor;
			npc.IgniteFor = 0;
			KillTimer(npc.IgniteTimer);
			npc.IgniteTimer = null;
			NPCList.SetArray(index, npc);
			return ticks;
		}
	}
	return 0;
}
*/

public Action NPC_TimerIgnite(Handle timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(entity > MaxClients)
	{
		int index = NPCList.FindValue(ref, NPCData::Ref);
		if(index != -1)
		{
			NPCData npc;
			NPCList.GetArray(index, npc);
			
			if(npc.IgniteFor > 0)
			{
				int client = GetClientOfUserId(npc.IgniteId);
				if(client && IsClientInGame(client))
				{
					npc.IgniteFor--;
					NPCList.SetArray(index, npc);
					
					float pos[3], ang[3];
					GetClientEyeAngles(client, ang);
					int weapon = EntRefToEntIndex(npc.IgniteRef);
					if(weapon > MaxClients && IsValidEntity(weapon))
					{
						float value = 8.0;
						
						value *= Attributes_FindOnWeapon(client, weapon, 2, true, 1.0);	  //For normal weapons
						
						value *= Attributes_FindOnWeapon(client, weapon, 410, true, 1.0); //For wand
						
						pos = WorldSpaceCenter(entity);
						
						SDKHooks_TakeDamage(entity, client, client, value, DMG_SLASH, weapon, ang, pos, false);
						//Setting burn dmg to slash cus i want it to work with melee!!!
						//Also yes this means burn and bleed are basically the same, excluding that burn doesnt stack.
						//In this case ill buff it so its 2x as good as bleed! or more in the future
						//Also now allows hp gain and other stuff for that reason. pretty cool.
					}
					else
					{
						return Plugin_Stop;
					}
					return Plugin_Continue;
				}
			}
			
			npc.IgniteTimer = null;
			NPCList.SetArray(index, npc);
		}
	}
	return Plugin_Stop;
}

float played_headshotsound_already [MAXTF2PLAYERS];

public Action NPC_TraceAttack(int victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& ammotype, int hitbox, int hitgroup)
{
	if(attacker < 1 || attacker > MaxClients || victim == attacker)
		return Plugin_Continue;
		
	if(inflictor < 1 || inflictor > MaxClients)
		return Plugin_Continue;
	/*
	if(GetEntProp(attacker, Prop_Send, "m_iTeamNum") == GetEntProp(victim, Prop_Send, "m_iTeamNum"))
	{
		damage = 0.0;
		return Plugin_Handled;
	}
	*/
//	if((damagetype & (DMG_BULLET)) || (damagetype & (DMG_BUCKSHOT))) // Needed, other crap for some reason can trigger headshots, so just make sure only bullets can do this.
	{
		if(hitgroup == HITGROUP_HEAD)
		{
			if(i_HeadshotAffinity[attacker] == 1)
			{
				damage *= 1.65;
			}
			else
			{
				damage *= 1.4;
			}
			if(i_CurrentEquippedPerk[attacker] == 5)
			{
				damage *= 1.25;
			}
			if(played_headshotsound_already[attacker] < GetGameTime())
			{
				int pitch = GetRandomInt(90, 110);
				played_headshotsound_already[attacker] = GetGameTime();
				switch(GetRandomInt(1, 2))
				{
					case 1:
					{
						EmitSoundToClient(attacker, "zombiesurvival/headshot1.wav", _, _, 90, _, 0.7, pitch);
					}
					case 2:
					{
						EmitSoundToClient(attacker, "zombiesurvival/headshot2.wav", _, _, 90, _, 0.7, pitch);
					}
				}
			}
			return Plugin_Changed;
		}
		else
		{
			if(i_HeadshotAffinity[attacker] == 1)
			{
				damage *= 0.75;
				return Plugin_Changed;
			}
			return Plugin_Continue;		
		}
	}
//	return Plugin_Continue;
}
		
static float f_CooldownForHurtHud[MAXPLAYERS];	
//Otherwise we get kicks if there is too much hurting going on.

public void NPC_OnTakeDamage_Post(int victim, int attacker, int inflictor, float damage, int damagetype) 
{
	if(attacker < 1 || attacker > MaxClients)
		return;
	/*
	if(GetEntProp(attacker, Prop_Send, "m_iTeamNum") == GetEntProp(victim, Prop_Send, "m_iTeamNum"))
	{
		return;
	}
	*/
	int Health = GetEntProp(victim, Prop_Data, "m_iHealth");
	int MaxHealth = GetEntProp(victim, Prop_Data, "m_iMaxHealth");
	
	float damage_Caclulation = damage;
	/*
	if(TF2_IsPlayerInCondition(attacker, TFCond_Buffed))
		damage_Caclulation *= 1.35;
		
	else if (damagetype & DMG_CRIT)
		damage_Caclulation *= 3.0;
		*/
		//dont bother lol
/*		
	//for some reason it doesnt do it by itself, im baffeled.

	if(Health < 0)
		damage_Caclulation += float(Health);
	
	if(damage_Caclulation > 0.0) //idk i guess my math is off or that singular/10 frames of them being still being there somehow impacts this, cannot go around this, delay is a must
		Damage_dealt_in_total[attacker] += damage_Caclulation;	//otherwise alot of other issues pop up.
	
	Damage_dealt_in_total[attacker] += damage_Caclulation;
	*/
	
	Damage_dealt_in_total[attacker] += damage_Caclulation; //i dont know, i give up.
	
	if(f_CooldownForHurtHud[attacker] < GetGameTime())
	{
		f_CooldownForHurtHud[attacker] = GetGameTime() + 0.1;
		
		int red = 255;
		int green = 255;
		int blue = 0;
				
		red = Health * 255  / MaxHealth;
		//	blue = GetEntProp(entity, Prop_Send, "m_iHealth") * 255  / Building_Max_Health[entity];
		green = Health * 255  / MaxHealth;
				
		red = 255 - red;
			
		if(Health <= 0)
		{
			red = 255;
			green = 0;
			blue = 0;
		}
		
		SetHudTextParams(-1.0, 0.2, 1.0, red, green, blue, 255, 0, 0.01, 0.01, 2.0);
		ShowSyncHudText(attacker, SyncHud, "%d / %d", Health, MaxHealth);
	}
}

public void Func_Breakable_Post(int victim, int attacker, int inflictor, float damage, int damagetype) 
{
	if(attacker < 1 || attacker > MaxClients)
		return;
	
	int Health = GetEntProp(victim, Prop_Data, "m_iHealth");
	
	float damage_Caclulation = damage;
		
	//for some reason it doesnt do it by itself, im baffeled.

	if(Health < 0)
		damage_Caclulation += float(Health);
	
	if(damage_Caclulation > 0.0) //idk i guess my math is off or that singular/10 frames of them being still being there somehow impacts this, cannot go around this, delay is a must
		Damage_dealt_in_total[attacker] += damage_Caclulation;	//otherwise alot of other issues pop up.
	
	Damage_dealt_in_total[attacker] += damage_Caclulation;
	
	
	Event event = CreateEvent("npc_hurt");
	if (event) 
	{
		event.SetInt("entindex", victim);
		event.SetInt("health", Health > 0 ? Health : 0);
		event.SetInt("damageamount", RoundToFloor(damage));
		event.SetBool("crit", (damagetype & DMG_ACID) == DMG_ACID);

		if (attacker > 0 && attacker <= MaxClients)
		{
			event.SetInt("attacker_player", GetClientUserId(attacker));
			event.SetInt("weaponid", 0);
		}
		else 
		{
			event.SetInt("attacker_player", 0);
			event.SetInt("weaponid", 0);
		}

		event.Fire();
	}
	
	if(f_CooldownForHurtHud[attacker] < GetGameTime())
	{
		f_CooldownForHurtHud[attacker] = GetGameTime() + 0.1;
		
		SetHudTextParams(-1.0, 0.2, 1.0, 255, 200, 200, 255, 0, 0.01, 0.01, 2.0);
		ShowSyncHudText(attacker, SyncHud, "%d", Health);
	}
}
public void Map_BaseBoss_Damage_Post(int victim, int attacker, int inflictor, float damage, int damagetype) 
{
	if(attacker < 1 || attacker > MaxClients)
		return;
	
	int Health = GetEntProp(victim, Prop_Data, "m_iHealth");
	
	float damage_Caclulation = damage;
		
	//for some reason it doesnt do it by itself, im baffeled.

	if(Health < 0)
		damage_Caclulation += float(Health);
	
	if(damage_Caclulation > 0.0) //idk i guess my math is off or that singular/10 frames of them being still being there somehow impacts this, cannot go around this, delay is a must
		Damage_dealt_in_total[attacker] += damage_Caclulation;	//otherwise alot of other issues pop up.
	
	Damage_dealt_in_total[attacker] += damage_Caclulation;
	
	if(f_CooldownForHurtHud[attacker] < GetGameTime())
	{
		f_CooldownForHurtHud[attacker] = GetGameTime() + 0.1;
		
		SetHudTextParams(-1.0, 0.2, 1.0, 255, 200, 200, 255, 0, 0.01, 0.01, 2.0);
		ShowSyncHudText(attacker, SyncHud, "%d", Health);
	}
}

public Action NPC_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(damagetype & DMG_DROWN)
	{
		damage *= 5.0;
		return Plugin_Changed;	
	}
	
	if(attacker < 1 ||/* attacker > MaxClients ||*/ victim == attacker)
		return Plugin_Continue;
		
	if(GetEntProp(attacker, Prop_Send, "m_iTeamNum") == GetEntProp(victim, Prop_Send, "m_iTeamNum"))
	{
		damage = 0.0;
		return Plugin_Handled;
	}	
	
	
	/*
		The Bloons:
		
		DMG_BLAST = Good vs Lead, Bad vs Black
		
		DMG_VEHICLE = Good vs Lead, Bad vs White
		
		DMG_BURN, DMG_SONIC = Good vs Lead, Bad vs Purple
		
		DMG_PLASMA = Bad vs Purple, good against lead
		
		DMG_SHOCK = Bad vs purple and lead
	*/
	
	damagetype |= DMG_NOCLOSEDISTANCEMOD; //Remove damage ramp up cus it makes camping like 9458349573483285734895x more efficient then walking to wallmart
	damagetype &= ~DMG_USEDISTANCEMOD; //Remove damage falloff.
	/*
	if(i_CurrentEquippedPerk[attacker] == 3)
	{
		damage *= 1.20;
		
	}
	*/
	if(attacker <= MaxClients)
	{
		if(dieingstate[attacker] > 0)
		{
			damage *= 0.25;
		}
		if(Increaced_Overall_damage_Low[attacker] > GetGameTime())
		{
			damage *= 1.25;
		}
		if(damagecustom>=TF_CUSTOM_SPELL_TELEPORT && damagecustom<=TF_CUSTOM_SPELL_BATS)
		{
			//nope, no fireball damage. or any mage damage.
			damage = 0.0;
			return Plugin_Handled;
		}
		
		if(EscapeMode)
		{
			if(IsValidEntity(weapon))
			{
				if(!IsWandWeapon(weapon)) //make sure its not a wand.
				{
					char melee_classname[64];
					GetEntityClassname(weapon, melee_classname, 64);
					
					if (TFWeaponSlot_Melee == TF2_GetClassnameSlot(melee_classname))
						damage *= 1.25;
				}
			}
		}
		int index = NPCList.FindValue(EntIndexToEntRef(victim), NPCData::Ref);
		if(index != -1)
		{
			NPCData npc;
			NPCList.GetArray(index, npc);
			npc.LastHitId = GetClientUserId(attacker);
			npc.DamageBits = damagetype;
			
			if(weapon > MaxClients)
				npc.LastHitWeaponRef = EntIndexToEntRef(weapon);
			else
				npc.LastHitWeaponRef = -1;
				
			NPCList.SetArray(index, npc);
		}
		
		Attributes_OnHit(attacker, victim, weapon, damage, damagetype);
					
		if(i_BarbariansMind[attacker] == 1)	// Deal extra damage with melee, but none with everything else
		{
			if(damagetype & (DMG_CLUB|DMG_SLASH)) // if you want anything to be melee based, just give them this.
				damage *= 1.25;
			else
				damage = 0.0;
		}
	}
	 //This only ever effects base_bosses so dont worry about sentries hurting you
	if(!(damagetype & DMG_SLASH)) //Use dmg slash for any npc that shouldnt be scaled.
	{
		char classname[32];
		if(IsValidEntity(inflictor) && inflictor>MaxClients)// && attacker<=MaxClients)
		{
			GetEntityClassname(inflictor, classname, sizeof(classname));
			if(StrEqual(classname, "obj_sentrygun"))
			{
				if(EscapeMode) //BUFF SENTRIES DUE TO NO PERKS IN ESCAPE!!!
				{
					damage *= 4.0;
				}
				if(Increaced_Sentry_damage_Low[inflictor] > GetGameTime())
				{
					damage *= 1.15;
				}
				else if(Increaced_Sentry_damage_High[inflictor] > GetGameTime())
				{
					damage *= 1.3;
				}
			}
			else if(StrEqual(classname, "base_boss") && b_IsAlliedNpc[inflictor]) //add a filter so it only does it for allied base_bosses
			{
				int Wave_Count = Waves_GetRound() + 1;
				if(!EscapeMode) //Buff in escapemode overall!
				{
					if(Wave_Count <= 10)
						damage *= 0.5;
						
					else if(Wave_Count <= 15)
						damage *= 1.25;
					
					else if(Wave_Count <= 20)
						damage *= 2.0;
						
					else if(Wave_Count <= 25)
						damage *= 3.0;
						
					else if(Wave_Count <= 30)
						damage *= 7.0;
						
					else if(Wave_Count <= 40)
						damage *= 10.0;
						
					else if(Wave_Count <= 45)
						damage *= 30.0;
					
					else if(Wave_Count <= 50)
						damage *= 45.0;
					
					else if(Wave_Count <= 60)
						damage *= 60.0;
					
					else
						damage *= 100.0;
				}
				else
				{
					damage *= 1.5;
				}
			}
		}
		if(attacker <= MaxClients && IsValidEntity(weapon))
		{
			if(i_ArsenalBombImplanter[weapon] > 0)
			{
				if(f_ChargeTerroriserSniper[weapon] > 149.0)
				{
					i_HowManyBombsOnThisEntity[victim][attacker] += 3;
				}
				else
				{
					i_HowManyBombsOnThisEntity[victim][attacker] += 1;
				}
				Apply_Particle_Teroriser_Indicator(victim);
				damage = 0.0;
			}
			
			/*
			for (int client = 1; client <= MaxClients; client++)
			{
				i_HowManyBombsOnThisEntity[victim][client] = 0; //to clean on death ofc.
			}
			*/
			GetEntityClassname(weapon, classname, sizeof(classname));
			if(!StrContains(classname, "tf_weapon_knife", false))
			{
				if(IsBehindAndFacingTarget(attacker, victim))
				{
					int viewmodel = GetEntPropEnt(attacker, Prop_Send, "m_hViewModel");
					int melee = GetIndexOfWeaponSlot(attacker, TFWeaponSlot_Melee);
					if(melee != 4 && melee != 1003 && viewmodel>MaxClients && IsValidEntity(viewmodel))
					{
						EmitSoundToAll("weapons/knife_swing_crit.wav", attacker, _, _, _, 0.7);
						RequestFrame(DoMeleeAnimationFrameLater, attacker);
					//	damagetype |= DMG_CRIT; For some reason post ontakedamage doenst like crits. Shits wierd man.
						damage *= 3.00;
						damage *= 1.75;
						
						if(EscapeMode)
							damage *= 1.35;
						
					//	SDKCall_PlaySpecificSequence(attacker, "Melee_Overhand_Swing"); //Melee_Overhand_Swing, ty 42!!
					//	SDKCall_DoAnimationEvent(attacker, 21, 150);//test
				
						if(!(GetClientButtons(attacker) & IN_DUCK)) //This shit only works sometimes, i blame tf2 for this.
						{
							
							RequestFrame(Try_Backstab_Anim_Again, attacker);
							TE_Start("PlayerAnimEvent");
							Animation_Setting[attacker] = 1;
							Animation_Index[attacker] = 33;
							TE_WriteNum("m_iPlayerIndex", attacker);
							TE_WriteNum("m_iEvent", Animation_Setting[attacker]);
							TE_WriteNum("m_nData", Animation_Index[attacker]);
							TE_SendToAll();
						}
						if(melee == 356)
						{
							StartHealingTimer(attacker, 0.1, 1, 10);
							SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime()+1.5);
							SetEntPropFloat(attacker, Prop_Send, "m_flNextAttack", GetGameTime()+1.5);
						}
						else if(melee == 225)
						{
							StartHealingTimer(attacker, 0.1, 2, 25);
							SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime()+1.0);
							SetEntPropFloat(attacker, Prop_Send, "m_flNextAttack", GetGameTime()+1.0);
						}
						else if(melee == 727)
						{
							//THIS MELEE WILL HAVE SPECIAL PROPERTIES SO ITS RECONISED AS A SPY MELEE AT ALL TIMES!
							StartHealingTimer(attacker, 0.1, 3, 25);
							SepcialBackstabLaughSpy(attacker);
							damage *= 0.75; //Nerf the dmg abit for the last knife as itsotheriwse ridicilous
						}
						else
						{
							SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime()+1.5);
							SetEntPropFloat(attacker, Prop_Send, "m_flNextAttack", GetGameTime()+1.5);	
						}
					}
				}
			}
			/*
			else
			{	
				int weaponindex = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
				//Check if the weapon is a laser weapon, these weapons have wierd shit that causes people to crash with the way we use them
				switch(weaponindex)
				{
					case 442: // Bison
					{
						PrintToChatAll("test");
						int viewmodel = GetEntPropEnt(attacker, Prop_Send, "m_hViewModel");
						SetEntProp(viewmodel, Prop_Send, "m_nSequence", 1);
					}
					case 588: // Pomson
					{
						int viewmodel = GetEntPropEnt(attacker, Prop_Send, "m_hViewModel");
						SetEntProp(viewmodel, Prop_Send, "m_nSequence", 1);
					}
					case 441: // Mangler
					{
						int viewmodel = GetEntPropEnt(attacker, Prop_Send, "m_hViewModel");
						SetEntProp(viewmodel, Prop_Send, "m_nSequence", 1);
					}
				}
			}
			*/
		}
	}
	
	switch (damagecustom) //Make sure taunts dont do any damage, cus op as fuck
	{
		case TF_CUSTOM_TAUNT_HADOUKEN, TF_CUSTOM_TAUNT_HIGH_NOON, TF_CUSTOM_TAUNT_GRAND_SLAM, TF_CUSTOM_TAUNT_FENCING,
		TF_CUSTOM_TAUNT_ARROW_STAB, TF_CUSTOM_TAUNT_GRENADE, TF_CUSTOM_TAUNT_BARBARIAN_SWING,
		TF_CUSTOM_TAUNT_UBERSLICE, TF_CUSTOM_TAUNT_ENGINEER_SMASH, TF_CUSTOM_TAUNT_ENGINEER_ARM, TF_CUSTOM_TAUNT_ARMAGEDDON:
		{
			damage = 0.0;
		}
		
	}	//Remove annoying instakill taunts
	
	return Plugin_Changed;
}


void DoMeleeAnimationFrameLater(int attacker)
{
	int viewmodel = GetEntPropEnt(attacker, Prop_Send, "m_hViewModel");
	int melee = GetIndexOfWeaponSlot(attacker, TFWeaponSlot_Melee);
	if(melee != 4 && melee != 1003 && viewmodel>MaxClients && IsValidEntity(viewmodel))
	{
		int animation = 42;
		switch(melee)
		{
			case 225, 356, 423, 461, 574, 649, 1071, 30758:  //Your Eternal Reward, Conniver's Kunai, Saxxy, Wanga Prick, Big Earner, Spy-cicle, Golden Frying Pan, Prinny Machete
				animation=16;

			case 638:  //Sharp Dresser
				animation=32;
		}
		SetEntProp(viewmodel, Prop_Send, "m_nSequence", animation);
	}
	
}
/*
enum PlayerAnimEvent_t
{
0	PLAYERANIMEVENT_ATTACK_PRIMARY, 	
1	PLAYERANIMEVENT_ATTACK_SECONDARY,
2	PLAYERANIMEVENT_ATTACK_GRENADE,
3	PLAYERANIMEVENT_RELOAD,
4	PLAYERANIMEVENT_RELOAD_LOOP,
5	PLAYERANIMEVENT_RELOAD_END,
6	PLAYERANIMEVENT_JUMP,
7	PLAYERANIMEVENT_SWIM,
8	PLAYERANIMEVENT_DIE,
9	PLAYERANIMEVENT_FLINCH_CHEST,
10	PLAYERANIMEVENT_FLINCH_HEAD,
11	PLAYERANIMEVENT_FLINCH_LEFTARM,
12	PLAYERANIMEVENT_FLINCH_RIGHTARM,
13	PLAYERANIMEVENT_FLINCH_LEFTLEG,
14	PLAYERANIMEVENT_FLINCH_RIGHTLEG,
15	PLAYERANIMEVENT_DOUBLEJUMP,

	// Cancel.
16	PLAYERANIMEVENT_CANCEL,
17	PLAYERANIMEVENT_SPAWN,

	// Snap to current yaw exactly
18	PLAYERANIMEVENT_SNAP_YAW,

19	PLAYERANIMEVENT_CUSTOM,				// Used to play specific activities
20	PLAYERANIMEVENT_CUSTOM_GESTURE,
21	PLAYERANIMEVENT_CUSTOM_SEQUENCE,	// Used to play specific sequences
22	PLAYERANIMEVENT_CUSTOM_GESTURE_SEQUENCE,

	// TF Specific. Here until there's a derived game solution to this.
23	PLAYERANIMEVENT_ATTACK_PRE,
24	PLAYERANIMEVENT_ATTACK_POST,
25	PLAYERANIMEVENT_GRENADE1_DRAW,
26	PLAYERANIMEVENT_GRENADE2_DRAW,
27	PLAYERANIMEVENT_GRENADE1_THROW,
28	PLAYERANIMEVENT_GRENADE2_THROW,
29	PLAYERANIMEVENT_VOICE_COMMAND_GESTURE,
30	PLAYERANIMEVENT_DOUBLEJUMP_CROUCH,
31	PLAYERANIMEVENT_STUN_BEGIN,
32	PLAYERANIMEVENT_STUN_MIDDLE,
33	PLAYERANIMEVENT_STUN_END,
34	PLAYERANIMEVENT_PASSTIME_THROW_BEGIN,
35	PLAYERANIMEVENT_PASSTIME_THROW_MIDDLE,
36	PLAYERANIMEVENT_PASSTIME_THROW_END,
37	PLAYERANIMEVENT_PASSTIME_THROW_CANCEL,

38	PLAYERANIMEVENT_ATTACK_PRIMARY_SUPER,

39	PLAYERANIMEVENT_COUNT
};
*/
public void Try_Backstab_Anim_Again(int attacker)
{
	RequestFrame(Try_Backstab_Anim_Again2, attacker);
	TE_Start("PlayerAnimEvent");
	TE_WriteNum("m_iPlayerIndex", attacker);
	TE_WriteNum("m_iEvent", Animation_Setting[attacker]);
	TE_WriteNum("m_nData", Animation_Index[attacker]);
	TE_SendToAll();
					
}
public void Try_Backstab_Anim_Again2(int attacker)
{
	TE_Start("PlayerAnimEvent");
	TE_WriteNum("m_iPlayerIndex", attacker);
	TE_WriteNum("m_iEvent", Animation_Setting[attacker]);
	TE_WriteNum("m_nData", Animation_Index[attacker]);
	TE_SendToAll();
	if(Dont_Crouch[attacker] > 0)
		RequestFrame(Try_Backstab_Anim_Again3, attacker);
					
}
public void Try_Backstab_Anim_Again3(int attacker)
{
	TE_Start("PlayerAnimEvent");
	TE_WriteNum("m_iPlayerIndex", attacker);
	TE_WriteNum("m_iEvent", Animation_Setting[attacker]);
	TE_WriteNum("m_nData", Animation_Index[attacker]);
	TE_SendToAll();
					
}

public void NPC_CheckDead()
{
	NPCData npc;
	for(int i=NPCList.Length-1; i>=0; i--)
	{
		NPCList.GetArray(i, npc);
		int npc_index = EntRefToEntIndex(npc.Ref);
		if(npc_index <= MaxClients)
		{
			RequestFrame(NPC_SpawnNextRequestFrame, false);
			//make sure that if they despawned instead of dying, that their shit still gets cleaned just in case.
			Zombies_Currently_Still_Ongoing -= 1;
			
			NPCList.Erase(i);
		}
		else
		{
			CClotBody npcstats = view_as<CClotBody>(npc_index);
			if(!npcstats.m_bThisNpcIsABoss)
			{
				if(Zombies_Currently_Still_Ongoing <= 3 && Zombies_Currently_Still_Ongoing > 0)
					SetEntProp(npc_index, Prop_Send, "m_bGlowEnabled", true);
				else
					SetEntProp(npc_index, Prop_Send, "m_bGlowEnabled", false);
			}
		}
	}
}

void NPC_DeadEffects(int entity)
{
	NPCData npc;
	for(int i=NPCList.Length-1; i>=0; i--)
	{
		NPCList.GetArray(i, npc);
		if(EntRefToEntIndex(npc.Ref) == entity)
		{
			RequestFrame(NPC_SpawnNextRequestFrame, false);
			Zombies_Currently_Still_Ongoing -= 1;
			/*
			RequestFrame(entity, Remove_
			SDKUnhook(entity, SDKHook_TraceAttack, NPC_TraceAttack);
			SDKUnhook(entity, SDKHook_OnTakeDamage, NPC_OnTakeDamage);
			SDKUnhook(entity, SDKHook_OnTakeDamagePost, NPC_OnTakeDamage_Post);
			*/
			DropPowerupChance(entity);
			Gift_DropChance(entity);
			int WeaponLastHit = EntRefToEntIndex(npc.LastHitWeaponRef);
			int client = GetClientOfUserId(npc.LastHitId);
			if(client && IsClientInGame(client))
			{
				GiveXP(client, 1);
				NPC_Killed_Show_Hud(client, entity, WeaponLastHit, NPC_Names[i_NpcInternalId[entity]], npc.DamageBits);
				Attributes_OnKill(client, WeaponLastHit);
				GiveNamedItem(client, NPC_Names[i_NpcInternalId[entity]]);
			}
			
			NPCList.Erase(i);
			break;
		}
	}
	RemoveNpcThingsAgain(entity);
}

void GiveNamedItem(int client, const char[] name)
{
	if(name[0] && GetFeatureStatus(FeatureType_Native, "TextStore_GetItems") == FeatureStatus_Available)
	{
		int length = TextStore_GetItems();
		for(int i; i<length; i++)
		{
			static char buffer[64];
			TextStore_GetItemName(i, buffer, sizeof(buffer));
			if(StrEqual(buffer, name, false))
			{
				int amount;
				TextStore_GetInv(client, i, amount);
				TextStore_SetInv(client, i, amount + 1);
				TextStore_Cash(client, 1);
				break;
			}
		}
	}
}

void CleanAllAppliedEffects(int entity)
{
	for (int client = 1; client <= MaxClients; client++)
	{
		i_HowManyBombsOnThisEntity[entity][client] = 0; //to clean on death ofc.
	}
}