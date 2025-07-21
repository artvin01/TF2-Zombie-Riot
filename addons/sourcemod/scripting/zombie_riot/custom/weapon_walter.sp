#pragma semicolon 1
#pragma newdecls required

static float BombCooldown;
static Handle NukeTimer[MAXPLAYERS];

void Walter_Enable(int client, int weapon)
{
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_WALTER)
	{
		DataPack pack = new DataPack();
		RequestFrame(ApplyBuilderAttributes, pack);
		pack.WriteCell(EntIndexToEntRef(client));
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}

static void ApplyBuilderAttributes(DataPack pack)
{
	pack.Reset();
	int client = EntRefToEntIndex(pack.ReadCell());
	int weapon = EntRefToEntIndex(pack.ReadCell());
	delete pack;

	if(IsValidClient(client) && IsValidEntity(weapon))
	{
		//when the weapon is created.
		float attack_speed = Attributes_GetOnPlayer(client, 343, true); //Sentry attack speed bonus
		Attributes_SetMulti(weapon, 6, attack_speed);
		Attributes_SetMulti(weapon, 97, attack_speed);

		float damage = Attributes_GetOnPlayer(client, 287, true);			//Sentry damage bonus
		damage *= 0.75;

		Attributes_Set(weapon, 2, damage);
	}
}

void Walter_NPCTakeDamage(int victim, int attacker, float &damage, int weapon)
{
	if(weapon == -1)
	{
		// Terroriser Bomb Damage
		return;
	}

	bool explosiveDawn;
	char classname[36];
	if(GetEntityClassname(weapon, classname, sizeof(classname)))
	{
		explosiveDawn = !StrContains(classname, "tf_weapon_rocket", false);
	}

	if(fabs(BombCooldown - GetGameTime()) > 0.2)	// Main Target
	{
		BombCooldown = GetGameTime();

		damage *= 2.0;	// Main target bonus
		
		if(i_HowManyBombsOnThisEntity[victim][attacker] < 1)
		{

			f_BombEntityWeaponDamageApplied[victim][attacker] += damage * 1.75;
			i_HowManyBombsOnThisEntity[victim][attacker] += 1;
			i_HowManyBombsHud[victim] += 1;
			Apply_Particle_Teroriser_Indicator(victim);
		}

		damage *= 1.25;	// Talent 1 bonus
	}

	if(i_HowManyBombsOnThisEntity[victim][attacker] > 0)
	{
		if(explosiveDawn || (GetURandomInt() % 20) > 16)
		{
			EmitSoundToAll(TRIP_ARMED, victim, _, 85);
			Cause_Terroriser_Explosion(attacker, victim, false/*, WalterExplodeBefore*/);
		}
	}

	if(explosiveDawn)
		damage *= 2.0;	// Skill bonus
}

/*

static float WalterExplodeBefore(int attacker, int victim, float &damage, int weapon)
{
	FreezeNpcInTime(victim, 0.35);
	return 0.0;
}
*/
static Action Weapon_Walter_Timer(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	if(IsClientInGame(client) && IsPlayerAlive(client))
	{
		int oldWeapon = EntRefToEntIndex(pack.ReadCell());
		if(oldWeapon != -1)
		{
			int weapon = EntRefToEntIndex(pack.ReadCell());
			if(weapon != -1)
			{
				if(weapon == GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon"))
					return Plugin_Continue;
			}

			Ability_Apply_Cooldown(client, 2, 100.0, oldWeapon);
		}

		Store_RemoveSpecificItem(client, "Explosive Dawn");
		Store_ApplyAttribs(client);
		Store_GiveAll(client, GetClientHealth(client));
	}

	NukeTimer[client] = null;
	return Plugin_Stop;
}

public void Weapon_Walter_M2(int client, int weapon, bool &result, int slot)
{
	if(!NukeTimer[client])
	{
		float cooldown = Ability_Check_Cooldown(client, 2);
		if(cooldown > 0.0)
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Ability has cooldown", cooldown);
		}
		else
		{
			Rogue_OnAbilityUse(client, weapon);

			MakePlayerGiveResponseVoice(client, 1); //haha!
			int entity = Store_GiveSpecificItem(client, "Explosive Dawn");
			SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", entity);
			ViewChange_Update(client);

			DataPack pack;
			NukeTimer[client] = CreateDataTimer(0.2, Weapon_Walter_Timer, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
			pack.WriteCell(EntIndexToEntRef(entity));

			static int iAmmoTable;
			if(!iAmmoTable)
				iAmmoTable = FindSendPropInfo("CBaseCombatWeapon", "m_iClip1");
			
			SetEntData(entity, iAmmoTable, 6);
			SetEntProp(entity, Prop_Send, "m_iClip1", 6);
			ClipSaveSingle(client, entity);
			ClipSaveSingle(client, entity);

			ClientCommand(client, "playgamesound mvm/mvm_tele_activate.wav");

			CreateTimer(0.1, Timer_Walter_Summon, GetClientUserId(client));
			CreateTimer(1.6, Timer_Walter_Summon, GetClientUserId(client));
			
			Ability_Apply_Cooldown(client, 2, 180.0, weapon);
		}
	}
}

static Action Timer_Walter_Summon(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	if(client && IsPlayerAlive(client))
	{
		if(Object_CanBuild(ObjectRevenant_CanBuild, client))
		{
			float vecPos[3], vecAng[3];
			GetClientAbsOrigin(client, vecPos);
			GetClientEyeAngles(client, vecAng);
			vecAng[0] = 0.0;
			vecAng[2] = 0.0;

			int entity = NPC_CreateByName("obj_revenant", client, vecPos, vecAng, GetTeam(client));
			if(entity != -1)
			{
				ObjectGeneric obj = view_as<ObjectGeneric>(entity);
				int health = GetEntProp(obj.index, Prop_Data, "m_iHealth");
				int maxhealth = GetEntProp(obj.index, Prop_Data, "m_iMaxHealth");
				int expected = RoundFloat(obj.BaseHealth * Object_GetMaxHealthMulti(client));
				if(maxhealth && expected && maxhealth != expected)
				{
					float change = float(expected) / float(maxhealth);

					maxhealth = expected;
					health = RoundFloat(float(health) * change);
					
					SetEntProp(obj.index, Prop_Data, "m_iMaxHealth", maxhealth);
					SetEntProp(obj.index, Prop_Data, "m_iHealth", health);
				}

				SetEntProp(obj.index, Prop_Data, "m_iRepairMax", 0);
				SetEntProp(obj.index, Prop_Data, "m_iRepair", 0);
				GiveBuildingMetalCostOnBuy(entity, 0);
				//Building_PlayerWieldsBuilding(client, entity);
				Barracks_UpdateEntityUpgrades(entity, client, true);
			}
		}
		else
		{
			SetDefaultHudPosition(client);
			ShowSyncHudText(client, SyncHud_Notifaction, "Barricade Limit Reached");
		}
	}
	return Plugin_Continue;
}