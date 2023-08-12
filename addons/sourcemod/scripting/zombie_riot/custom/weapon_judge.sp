#pragma semicolon 1
#pragma newdecls required

#define JUDGE_MAX_CLIP 5

Handle h_TimerJudgeManagement[MAXPLAYERS+1] = {INVALID_HANDLE, ...};
static float f_JudgeHudDelay[MAXTF2PLAYERS];
static bool b_JudgeFullAmmoSound[MAXTF2PLAYERS];

void Judge_Map_Precache() //Anything that needs to be precaced like sounds or something.
{
	Zero(f_JudgeHudDelay);
	Zero(b_JudgeFullAmmoSound);
	PrecacheSound("player/recharged.wav");
}

void Reset_stats_Judge_Singular(int client) //This is on disconnect/connect
{
	if (h_TimerJudgeManagement[client] != INVALID_HANDLE)
	{
		KillTimer(h_TimerJudgeManagement[client]);
	}	
	h_TimerJudgeManagement[client] = INVALID_HANDLE;
}


public void Enable_Judge(int client, int weapon) 
{
	if (h_TimerJudgeManagement[client] != INVALID_HANDLE)
	{
		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_JUDGE || i_CustomWeaponEquipLogic[weapon] == WEAPON_JUDGE_PAP) 
		{
			//Is the weapon it again?
			//Yes?
			KillTimer(h_TimerJudgeManagement[client]);
			h_TimerJudgeManagement[client] = INVALID_HANDLE;
			DataPack pack;
			h_TimerJudgeManagement[client] = CreateDataTimer(0.1, Timer_Management_Judge, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_JUDGE || i_CustomWeaponEquipLogic[weapon] == WEAPON_JUDGE_PAP)  //9 Is for Passanger
	{
		DataPack pack;
		h_TimerJudgeManagement[client] = CreateDataTimer(0.1, Timer_Management_Judge, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}



public Action Timer_Management_Judge(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	if(IsValidClient(client))
	{
		if (IsClientInGame(client))
		{
			if (IsPlayerAlive(client))
			{
				Judge_Cooldown_Logic(client, EntRefToEntIndex(pack.ReadCell()));
			}
			else
				Kill_Timer_Judge(client);
		}
		else
			Kill_Timer_Judge(client);
	}
	else
		Kill_Timer_Judge(client);
		
	return Plugin_Continue;
}

public void Judge_Cooldown_Logic(int client, int weapon)
{
	if (!IsValidMulti(client))
		return;
		
	if(IsValidEntity(weapon))
	{
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_JUDGE)
		{
			int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
			if(weapon_holding != weapon) //Only show if the weapon is actually in your hand right now.
			{
				if(f_JudgeHudDelay[client] < GetGameTime())
				{
					f_JudgeHudDelay[client] = GetGameTime() + GetJudgeReloadCooldown(3.0, client);
					Add_Back_One_Clip_Judge(weapon, client);
				}
			}
			else
			{
					f_JudgeHudDelay[client] = GetGameTime() + GetJudgeReloadCooldown(3.0, client);
			}
		}
		else if(i_CustomWeaponEquipLogic[weapon] == WEAPON_JUDGE_PAP)
		{
			int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
			if(weapon_holding != weapon) //Only show if the weapon is actually in your hand right now.
			{
				if(f_JudgeHudDelay[client] < GetGameTime())
				{
					f_JudgeHudDelay[client] = GetGameTime() + GetJudgeReloadCooldown(2.0, client);
					
					Add_Back_One_Clip_Judge(weapon, client);
				}
			}
			else
			{
				f_JudgeHudDelay[client] = GetGameTime() + GetJudgeReloadCooldown(2.0, client);
			}
		}
		else
		{
			Kill_Timer_Judge(client);
		}
	}
	else
	{
		Kill_Timer_Judge(client);
	}
}

public void Kill_Timer_Judge(int client)
{
	if (h_TimerJudgeManagement[client] != INVALID_HANDLE)
	{
		KillTimer(h_TimerJudgeManagement[client]);
		h_TimerJudgeManagement[client] = INVALID_HANDLE;
	}
}

void Add_Back_One_Clip_Judge(int entity, int client)
{
	int AmmoType = GetEntProp(entity, Prop_Send, "m_iPrimaryAmmoType");
	int CurrentReserveAmmo = GetAmmo(client, AmmoType);
	if(CurrentReserveAmmo < 1)
		return;
			
	int iAmmoTable = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
	int ammo = GetEntData(entity, iAmmoTable, 4);//Get ammo clip
	if(IsAmmoFullJudgeWeapon(ammo, client))
		return;

	b_JudgeFullAmmoSound[client] = false;
	//use to actually subtract one.
	AddAmmoClient(client, AmmoType ,-1,1.0, true);
	ammo += 1;
	SetEntData(entity, iAmmoTable, ammo, 4, true);
	Update_Ammo(client);
	IsAmmoFullJudgeWeapon(ammo, client);
}

bool IsAmmoFullJudgeWeapon(int ammo, int client)
{
	if(ammo > 4)
	{
		if(!b_JudgeFullAmmoSound[client])
		{
			EmitSoundToClient(client, "player/recharged.wav", client, SNDCHAN_AUTO, 75,_,1.0,100);
			b_JudgeFullAmmoSound[client] = true;
		}
		return true;
	}
	return false;
}

float GetJudgeReloadCooldown(float cooldown, int client)
{
	float returncooldown;
	returncooldown = cooldown;

	if(i_CurrentEquippedPerk[client] == 4) //speed cola
		returncooldown *= 0.65;

	return returncooldown;
}