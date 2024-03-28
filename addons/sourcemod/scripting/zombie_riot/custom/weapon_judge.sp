#pragma semicolon 1
#pragma newdecls required

#define JUDGE_MAX_CLIP 5

Handle h_TimerJudgeManagement[MAXPLAYERS+1] = {null, ...};
static float f_JudgeHudDelay[MAXTF2PLAYERS];
static bool b_JudgeFullAmmoSound[MAXTF2PLAYERS];
static int i_TraurusJudge[MAXTF2PLAYERS];

void Judge_Map_Precache() //Anything that needs to be precaced like sounds or something.
{
	Zero(f_JudgeHudDelay);
	Zero(b_JudgeFullAmmoSound);
	PrecacheSound("player/recharged.wav");
}

void Reset_stats_Judge_Singular(int client) //This is on disconnect/connect
{
	if (h_TimerJudgeManagement[client] != null)
	{
		delete h_TimerJudgeManagement[client];
	}	
	h_TimerJudgeManagement[client] = null;
}

public int TaurusExistant(int client)
{
	if(h_TimerJudgeManagement[client] != null)
	{
		int weapon = EntRefToEntIndex(i_TraurusJudge[client]);
		return weapon;
	}
	return -1;
}
public void Enable_Judge(int client, int weapon) 
{
	if (h_TimerJudgeManagement[client] != null)
	{
		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_JUDGE || i_CustomWeaponEquipLogic[weapon] == WEAPON_JUDGE_PAP) 
		{
			//Is the weapon it again?
			//Yes?
			delete h_TimerJudgeManagement[client];
			h_TimerJudgeManagement[client] = null;
			DataPack pack;
			h_TimerJudgeManagement[client] = CreateDataTimer(0.1, Timer_Management_Judge, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
			
			i_TraurusJudge[client] = EntIndexToEntRef(weapon);
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_JUDGE || i_CustomWeaponEquipLogic[weapon] == WEAPON_JUDGE_PAP)  //9 Is for Passanger
	{
		DataPack pack;
		h_TimerJudgeManagement[client] = CreateDataTimer(0.1, Timer_Management_Judge, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
		i_TraurusJudge[client] = EntIndexToEntRef(weapon);
	}
}



public Action Timer_Management_Judge(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		h_TimerJudgeManagement[client] = null;
		return Plugin_Stop;
	}	

	Judge_Cooldown_Logic(client, weapon);

	return Plugin_Continue;
}

public void Judge_Cooldown_Logic(int client, int weapon)
{
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_JUDGE)
	{
		int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(weapon_holding != weapon) //Only show if the weapon is actually in your hand right now.
		{
			if(f_JudgeHudDelay[client] < GetGameTime())
			{
				f_JudgeHudDelay[client] = GetGameTime() + GetJudgeReloadCooldown(6.0, client);
				Add_Back_One_Clip_Judge(weapon, client);
			}
		}
		else
		{
			f_JudgeHudDelay[client] = GetGameTime() + GetJudgeReloadCooldown(6.0, client);
		}
	}
	else if(i_CustomWeaponEquipLogic[weapon] == WEAPON_JUDGE_PAP)
	{
		int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(weapon_holding != weapon) //Only show if the weapon is actually in your hand right now.
		{
			if(f_JudgeHudDelay[client] < GetGameTime())
			{
				f_JudgeHudDelay[client] = GetGameTime() + GetJudgeReloadCooldown(4.0, client);
				
				Add_Back_One_Clip_Judge(weapon, client);
			}
		}
		else
		{
			f_JudgeHudDelay[client] = GetGameTime() + GetJudgeReloadCooldown(4.0, client);
		}
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
	DataPack pack = new DataPack();
	pack.WriteCell(GetClientUserId(client));
	pack.WriteCell(EntIndexToEntRef(entity));
	Update_Ammo(pack);
	IsAmmoFullJudgeWeapon(ammo, client);
}

int TaurusMaxAmmo()
{
	return 5;
}
bool IsAmmoFullJudgeWeapon(int ammo, int client)
{
	if(ammo >= TaurusMaxAmmo())
	{
		if(!b_JudgeFullAmmoSound[client])
		{
		//	EmitSoundToClient(client, "player/recharged.wav", client, SNDCHAN_AUTO, 75,_,1.0,100);
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