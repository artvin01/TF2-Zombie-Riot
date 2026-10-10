#pragma semicolon 1
#pragma newdecls required

static char g_ExtraSlashesSound[][] = {
	"weapons/samurai/tf_katana_slice_01.wav",
	"weapons/samurai/tf_katana_slice_02.wav",
	"weapons/samurai/tf_katana_slice_03.wav",
};
static Handle h_WeaponTimer[MAXPLAYERS] = {null, ...};

public void OperaMute_OnMapStart()
{
	PrecacheSoundArray(g_ExtraSlashesSound);
}

public void OperaMute_Created(int client, int weapon)
{
	DataPack pack = new DataPack();
	if(h_WeaponTimer[client] != null)
	{
		if(IsValidHandle(h_WeaponTimer[client]))
			delete h_WeaponTimer[client];
		h_WeaponTimer[client] = null;
	}
	if(Ritualist_ThereisRitualistNecrosis())
		ApplyStatusEffect(client, client, "Empty Notes", 999999.9);

	h_WeaponTimer[client] = CreateDataTimer(0.25, OpeaMute_ManaHud, pack, TIMER_REPEAT);
	pack.WriteCell(client);
	pack.WriteCell(EntIndexToEntRef(weapon));
	pack.WriteCell(EntIndexToEntRef(client));
	ApplyStatusEffect(client, client, "Shielding", 999999.9);
}
static Action OpeaMute_ManaHud(Handle timer, DataPack pack)
{
	pack.Reset();
	int clientindx = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	int client = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsValidEntity(weapon))
	{
		//Heartbroken_ApplyCoffinBack(clientindx, true);
		h_WeaponTimer[clientindx] = null;
		if(IsValidClient(client))
		{
			RemoveSpecificBuff(client, "Shielding");
			RemoveSpecificBuff(client, "Empty Notes");
		}
		return Plugin_Stop;
	}
	if(!HasSpecificBuff(client, "Empty Notes"))
	{
		if(Ritualist_ThereisRitualistNecrosis())
			ApplyStatusEffect(client, client, "Empty Notes", 999999.9);
	}
	return Plugin_Continue;
}


public void OperaMute_Attack1(int client, int weapon)
{
	OperaMute_MultiHitLogic(weapon);
}

#define OPERA_DMG_NERF_SWING 0.25

void OperaMute_MultiHitLogic(int weapon)
{
	float attackspeed = Attributes_Get(weapon, 6, 1.0);
	if(b_WeaponAttackSpeedModified[weapon] == 0)
	{
		b_WeaponAttackSpeedModified[weapon] = 5;
		attackspeed = (attackspeed * 0.25);
		Attributes_Set(weapon, 6, attackspeed);
		return;
	}

	if(b_WeaponAttackSpeedModified[weapon] == REDMIST_STRONG_SWING)
	{
		attackspeed = (attackspeed * 0.25);
		Attributes_Set(weapon, 6, attackspeed);
		b_WeaponAttackSpeedModified[weapon] = 5;
	}
	else
	{
		if(b_WeaponAttackSpeedModified[weapon] == 2)
		{
			attackspeed = (attackspeed / 0.25);
			Attributes_Set(weapon, 6, attackspeed);
		}
		b_WeaponAttackSpeedModified[weapon] -= 1;
	}
}

public void OperaMute_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int zr_custom_damage)
{
	if(CheckInHud())
		return;
	
	if(zr_custom_damage & ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED)
		return;


	int mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));
	if(zr_custom_damage & ZR_DAMAGE_REFLECT_LOGIC)
	{
		OperaMute_ManaDo(attacker, -RoundToNearest(float(mana_cost) * 1.0));
		Elemental_AddNecrosisDamage(victim, attacker, RoundToNearest(damage * 3.0), weapon);
		if(OpeaMute_DamageMulti(attacker))
		{
			bool PlaySound = false;
			if(f_MinicritSoundDelay[attacker] < GetGameTime())
			{
				PlaySound = true;
				f_MinicritSoundDelay[attacker] = GetGameTime() + 0.25;
			}
			DisplayCritAboveNpc(victim, attacker, PlaySound);
			damage *= 1.5;
		}
		return;
	}
	else
	{
		OperaMute_ManaDo(attacker, RoundToNearest(float(mana_cost) * 3.0));
		Elemental_AddNecrosisDamage(victim, attacker, RoundToNearest(damage * 1.65), weapon);
	}

	if(RedMistFinalSwing(weapon))
	{
		DataPack pack = new DataPack();
		pack.WriteCell(EntIndexToEntRef(victim));
		pack.WriteCell(EntIndexToEntRef(attacker));
		pack.WriteCell(EntIndexToEntRef(weapon));
		pack.WriteFloat(damage * 0.5);
		pack.WriteCell(12);
		RequestFrames(OperaMute_DamageInstances, 3, pack, true);
	}
	if(OpeaMute_DamageMulti(attacker))
	{
		bool PlaySound = false;
		if(f_MinicritSoundDelay[attacker] < GetGameTime())
		{
			PlaySound = true;
			f_MinicritSoundDelay[attacker] = GetGameTime() + 0.25;
		}
		DisplayCritAboveNpc(victim, attacker, PlaySound);
		damage *= 1.5;
	}
}


public void OperaMute_DamageInstances(DataPack pack)
{
	pack.Reset();
	int victim = EntRefToEntIndex(pack.ReadCell());
	int attacker = EntRefToEntIndex(pack.ReadCell());
	int weapon = EntRefToEntIndex(pack.ReadCell());
	float damage = pack.ReadFloat();
	if(!IsEntityAlive(victim))
	{
		delete pack;
		return;
	}
	if(IsValidEntity(victim) && IsValidEntity(attacker))
	{
		static float EnemyPos[3];
		WorldSpaceCenter(victim, EnemyPos);
		SDKHooks_TakeDamage(victim, attacker, attacker, damage, DMG_CLUB, weapon, _, EnemyPos, _, ZR_DAMAGE_REFLECT_LOGIC);
		EmitSoundToAll(g_ExtraSlashesSound[GetRandomInt(0, sizeof(g_ExtraSlashesSound) - 1)], victim, SNDCHAN_BODY, 90, _, 1.0, GetRandomInt(100,105));
	}
	int Repats = pack.ReadCell();
	if(Repats <= 0)
	{
		delete pack;
		return;
	}
	pack.Position--;
	pack.WriteCell(Repats - 1, false);
	RequestFrames(OperaMute_DamageInstances, 3, pack, true);
}


void OperaMute_DmgCalc(int client, int weapon, float &damage, bool checkvalidity = false)
{
	int mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));
	SDKhooks_SetManaRegenDelayTime(client, 1.5);
	Mana_Hud_Delay[client] = 0.0;

	if(mana_cost > Current_Mana[client])
	{
		damage = 0.0;
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
		return;
	}
	if(!checkvalidity)
	{
		damage *= Attributes_Get(weapon, 410, 1.0);
	}
}

bool OperaMute_Thereis()
{
	for (int client = 1; client <= MaxClients; client++)
	{
		if(h_WeaponTimer[client])
		{
			return true;
		}
	}
	return false;
}
void OperaMute_GiveShield(int client, int mana_cost)
{
	ApplyStatusEffect(client, client, "Shielding", 999999.9);
	if(mana_cost <= 0)
		mana_cost *= -1;

	Shielding_Add(client, mana_cost);
	Shielding_CapAt(client, RoundToNearest(max_mana[client] * 0.5));
	
	float chargerPos[3];
	float targPos[3];
	GetClientAbsOrigin(client, chargerPos);
	//ultra lazy
	if(HasSpecificBuff(client, "Empty Notes"))
	{
		for (int targ = 1; targ <= MaxClients; targ++)
		{
			if (targ != client && IsValidClient(targ) && IsValidClient(client) && HasSpecificBuff(targ, "Empty Notes"))
			{
				GetClientAbsOrigin(targ, targPos);
				if (Ritualist_IsNecro(targ) && GetVectorDistance(chargerPos, targPos, true) <= (500.0 * 500.0))
				{
					ApplyStatusEffect(client, targ, "Shielding", 999999.9);
					if(mana_cost <= 0)
						mana_cost *= -1;

					Shielding_Add(targ, mana_cost);
					Shielding_CapAt(targ, RoundToNearest(max_mana[client] * 0.25));

					if(IsIn_HitDetectionCooldown(client,targ, ShieldGiveEffectCD))
					{
						continue;
					}
					Set_HitDetectionCooldown(client,targ, GetGameTime() + 1.0, ShieldGiveEffectCD);

					int BeamIndex = ConnectWithBeam(client, targ, 70, 200, 70, 2.0, 2.0, 1.1, "sprites/laserbeam.vmt");
					SetEntityRenderFx(BeamIndex, RENDERFX_FADE_FAST);
					CreateTimer(1.0, Timer_RemoveEntity, EntIndexToEntRef(BeamIndex), TIMER_FLAG_NO_MAPCHANGE);
				}
			}
		}
	}

}
void OperaMute_ManaDo(int client, int mana_cost)
{
	SDKhooks_SetManaRegenDelayTime(client, 1.5);
	Mana_Hud_Delay[client] = 0.0;
	float ManaLogicIs = Mana_Regen_Level[client];
	ManaLogicIs *= 0.5;
	if(ManaLogicIs <= 1.0)
		ManaLogicIs = 1.0;
	Current_Mana[client] -= RoundToNearest(float(mana_cost) * ManaLogicIs);
	if(Current_Mana[client] <= 0)
		Current_Mana[client] = 0;

	delay_hud[client] = 0.0;
	OperaMute_GiveShield(client, mana_cost / 2);
}
bool OperaMute_WeaponHas(int client)
{
	if(h_WeaponTimer[client] == null)
		return false;

	return true;
}
bool OpeaMute_DamageMulti(int client)
{
	float MaxMana = max_mana[client];
	float CurrentMana = float(Current_Mana[client]);
	if(CurrentMana >= MaxMana)
	{
		return false;
	}
	float PercMana = CurrentMana / MaxMana;

	//between 30% and 70% mana
	if(PercMana >= 0.3 && PercMana <= 0.7)
	{
		return true;
	}
	return false;
}


void OperaMute_ManaHud(int client, int &red, int &green, int &blue)
{
	if(!OperaMute_WeaponHas(client))	
		return;

	red = 255;
	green = 0;
	blue = 0;
	if(!OpeaMute_DamageMulti(client))
		return;

	red = 0;
	green = 0;
	blue = 255;
}