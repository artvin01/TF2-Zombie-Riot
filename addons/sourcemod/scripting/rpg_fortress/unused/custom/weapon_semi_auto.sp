#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <tf2_stocks>

static bool InFrame[MAXPLAYERS];

public void Weapon_USPMatch_M1(int client, int weapon, bool crit, int slot)
{
	if(!InFrame[client])
	{
		DataPack pack = new DataPack();
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
		pack.WriteFloat(0.4);	// 0.5s -> 0.1s
		RequestFrame(Weapon_SemiAuto_Frame, pack);
	}
}

public void Weapon_DoubleUSPMatch_M1(int client, int weapon, bool crit, int slot)
{
	if(!InFrame[client])
	{
		DataPack pack = new DataPack();
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
		pack.WriteFloat(0.2);	// 0.25s -> 0.05s
		RequestFrame(Weapon_SemiAuto_Frame, pack);
	}
}

public void Weapon_SemiAuto_Frame(DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	if(IsClientInGame(client))
	{
		int weapon = EntRefToEntIndex(pack.ReadCell());
		if(weapon != INVALID_ENT_REFERENCE)
		{
			float gameTime = GetGameTime();
			float time = GetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack");
			if(time > gameTime)
			{
				if(GetClientButtons(client) & IN_ATTACK)
				{
					RequestFrame(Weapon_SemiAuto_Frame, pack);
					return;
				}

				time -= pack.ReadFloat();
				SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", time); 
			}
		}
	}

	delete pack;
	InFrame[client] = false;
}

void Weapon_TakeDamage_StunStick(int victim, int damagetype)
{
	if(damagetype & DMG_CLUB)
		FreezeNpcInTime(victim, 0.2);
}

void Weapon_TakeDamage_SilenceStick(int victim, int attacker, int damagetype)
{
	if(damagetype & DMG_CLUB)
		NpcStats_SilenceEnemy(victim, Stats_OriginiumPower(attacker));
}

public void Weapon_Overlord_M2(int client, int weapon, bool crit, int slot)
{
	float cooldown = Ability_Check_Cooldown(client, slot);
	if(cooldown < 0.0)
	{
		ApplyTempAttrib(weapon, 6, 0.33, 1.5);
		Ability_Apply_Cooldown(client, slot, 30.0);
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Ability has cooldown", cooldown);
	}
}