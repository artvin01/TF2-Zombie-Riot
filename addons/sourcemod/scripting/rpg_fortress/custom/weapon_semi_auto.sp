#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <tf2_stocks>

static bool InFrame[MAXTF2PLAYERS];

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
					RequestFrame(Weapon_USPMatch_Frame, pack);
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

void NPC_TakeDamage_StunStick(int victim, int damagetype)
{
	if(damagetype & DMG_CLUB)
		FreezeNpcInTime(victim, 0.25);
}