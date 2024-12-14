#define FLAMETAIL_ABILITY	"ui/killsound_electro.wav"

static Handle WeaponTimer[MAXTF2PLAYERS];
static int WeaponRef[MAXTF2PLAYERS] = {-1, ...};
static int WeaponLevel[MAXTF2PLAYERS];
static bool DodgeNext[MAXTF2PLAYERS];
static float DodgeFor[MAXTF2PLAYERS];
static bool DoubleHit[MAXTF2PLAYERS];
static bool KaziBuffed;

void Flametail_RoundStart()
{
	Zero(DodgeNext);
	Zero(DodgeFor);
	Zero(WeaponLevel);
	Zero(DoubleHit);
	KaziBuffed = false;
}

bool IsWeaponKazimierz(int weapon)
{
	return (i_WeaponArchetype[weapon] == 23 || i_CustomWeaponEquipLogic[weapon] == WEAPON_NEARL);
}
bool FlameTail_Global_Buff()
{
	return KaziBuffed;
}

void Flametail_Enable(int client, int weapon)
{
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_FLAMETAIL)
	{
		WeaponRef[client] = EntIndexToEntRef(weapon);
		delete WeaponTimer[client];

		WeaponLevel[client] = RoundFloat(Attributes_Get(weapon, 868, 0.0));

		switch(WeaponLevel[client])
		{
			case 0:
			{
				WeaponTimer[client] = CreateTimer(3.7 / ResourceRegenMulti, Flametail_Timer1, client, TIMER_REPEAT);
			}
			case 1, 2:
			{

			}
			default:
			{
				KaziBuffed = true;
			}
		}
	}
}

public Action Flametail_Timer1(Handle timer, int client)
{
	if(IsClientInGame(client))
	{
		int weapon = EntRefToEntIndex(WeaponRef[client]);
		if(weapon != INVALID_ENT_REFERENCE)
		{
			if(!Waves_InSetup() && weapon == GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon") && AllowMaxCashgainWaveCustom(client))
			{
				CashRecievedNonWave[client]++;
				CashSpent[client]--;
				AddCustomCashMadeThisWave(client, 1);
			}
			
			return Plugin_Continue;
		}
	}

	WeaponTimer[client] = null;
	return Plugin_Stop;
}

public void Weapon_Flametail_M2(int client, int weapon, bool crit, int slot)
{
	float cooldown = Ability_Check_Cooldown(client, slot);
	if(cooldown > 0.0 && !CvarInfiniteCash.BoolValue)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Ability has cooldown", cooldown);
	}
	else
	{
		Rogue_OnAbilityUse(weapon);
		MakePlayerGiveResponseVoice(client, 4);

		int cash;
		float damage = 1.0;

		switch(WeaponLevel[client])
		{
			case 1:	// E0
			{
				cooldown = 30.0;
				cash = 6;
			}
			case 2:	// E1
			{
				cooldown = 30.0;
				cash = 7;
			}
			case 3:	// S5
			{
				cooldown = 28.0;
				cash = 8;
				damage = 1.25;
			}
			case 4:	// S7
			{
				cooldown = 27.0;
				cash = 8;
				damage = 1.3;
			}
			default:	// S10
			{
				cooldown = 24.0;
				cash = 8;
				damage = 1.45;
			}
		}

		cash *= 3;

		if(WeaponLevel[client] > 1)
		{
			DodgeFor[client] = GetGameTime() + 4.0;
			TF2_AddCondition(client, TFCond_SpeedBuffAlly, 4.0);
		}
		
		if(damage != 1.0)
		{
			ApplyTempAttrib(weapon, 2, damage, 4.0);
			ApplyTempAttrib(weapon, 6, 0.7, 4.0);
		}

		DodgeNext[client] = true;
		
		if(!Waves_InSetup() && AllowMaxCashgainWaveCustom(client))
		{
			cash = RoundFloat(cash * ResourceRegenMulti);
			CashRecievedNonWave[client] += cash;
			CashSpent[client] -= cash;
			AddCustomCashMadeThisWave(client, cash);
		}

		Ability_Apply_Cooldown(client, slot, cooldown);
		ClientCommand(client, "playgamesound " ... FLAMETAIL_ABILITY);
		MakeBladeBloddy(client, true, weapon);
		DataPack pack;
		CreateDataTimer(4.0, Timer_ExtinguishThings, pack);
		pack.WriteCell(EntIndexToEntRef(client));
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}

public Action Timer_ExtinguishThings(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = EntRefToEntIndex(pack.ReadCell());
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		return Plugin_Stop;
	}
	MakeBladeBloddy(client, false, weapon);
	return Plugin_Stop;
}

void Flametail_NPCTakeDamage(int attacker, float &damage, int weapon, float damagePosition[3])
{
	if(DoubleHit[attacker] && EntIndexToEntRef(weapon) == WeaponRef[attacker])
	{
		DoubleHit[attacker] = false;
		
		if(WeaponLevel[attacker] > 2)
		{
			i_ExplosiveProjectileHexArray[weapon] = EP_DEALS_CLUB_DAMAGE;
			Explode_Logic_Custom(damage, attacker, attacker, weapon, damagePosition, 150.0, EXPLOSION_AOE_DAMAGE_FALLOFF + 0.1, 1.0, false, DodgeFor[attacker] > GetGameTime() ? 5 : 3);
		}
		else
		{
			damage *= 2.0;
		}
	}
}

void Flametail_SelfTakeDamage(int victim, float &damage, int damagetype)
{
	if(damagetype & DMG_SLASH)
		return;
	
	bool dodged;
	
	if(DodgeNext[victim])
	{
		// 100% Melee Dodge (One-Time)
		if(damagetype & DMG_CLUB)
		{
			dodged = true;
			DodgeNext[victim] = false;
		}
	}
	
	if(!dodged && KaziBuffed)
	{
		// Kazimierz Global Buff
		if(damagetype & DMG_CLUB)
		{
			int weapon = GetEntPropEnt(victim, Prop_Send, "m_hActiveWeapon");
			if(weapon != -1 && IsWeaponKazimierz(weapon))
			{
				bool found;

				for(int client = 1; client <= MaxClients; client++)
				{
					if(WeaponLevel[client] > 2 && IsClientInGame(client) && IsPlayerAlive(client) &&
					   !dieingstate[client] && TeutonType[client] == TEUTON_NONE &&
					   EntIndexToEntRef(GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon")) == WeaponRef[client])
					{
						found = true;
						break;
					}
				}

				if(found)
				{
					// Double Chance for Self
					float chance = WeaponLevel[victim] > 2 ? 0.22 : 0.11;

					// Chance cut in half during raids
					if(RaidbossIgnoreBuildingsLogic(1))
						chance *= 0.5;
					
					if(chance > GetURandomFloat())
						dodged = true;
				}
			}
		}
	}

	if(!dodged && DodgeFor[victim] && DodgeFor[victim] > GetGameTime())
	{
		// Ability Dodge Buff
		if((damagetype & DMG_CLUB) || WeaponLevel[victim] > 2)
		{
			float chance = 0.8;
			switch(WeaponLevel[victim])
			{
				case 2:
					chance = 0.4;
				
				case 3:
					chance = 0.6;
			}

			// Chance cut in half during raids
			if(RaidbossIgnoreBuildingsLogic(1))
				chance *= 0.5;
			
			if(chance > GetURandomFloat())
				dodged = true;
		}
	}

	if(dodged)
	{
		float pos[3];
		GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", pos);
		pos[2] += 82.0;
		TE_ParticleInt(g_particleMissText, pos);
		TE_SendToAll();

		damage = 0.0;

		if(WeaponLevel[victim] > 1)
			DoubleHit[victim] = true;
	}
}
