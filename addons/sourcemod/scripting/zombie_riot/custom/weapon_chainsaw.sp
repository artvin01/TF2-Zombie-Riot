#pragma semicolon 1
#pragma newdecls required
static Handle h_TimerChainSawWeaponManagement[MAXPLAYERS+1] = {null, ...};
static float f_ChainSawhuddelay[MAXPLAYERS+1]={0.0, ...};
static float f_ChainsawLoopSound[MAXPLAYERS+1]={0.0, ...};
static bool f_ChainsawPlaySound[MAXPLAYERS+1];
float f_AttackDelayChainsaw[MAXPLAYERS];	

static const char g_MeleeAttack[][] = {
	"npc/roller/blade_out.wav",
};

static const char g_MeleeHitSounds[][] = {
	"npc/manhack/grind_flesh1.wav",
	"npc/manhack/grind_flesh2.wav",
	"npc/manhack/grind_flesh3.wav",
};
static const char g_MeleeHitSoundFloor[][] = {
	"ambient/sawblade_impact1.wav",
	"ambient/sawblade_impact2.wav",
};

void Mapstart_Chainsaw()
{
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttack);
	PrecacheSoundArray(g_MeleeHitSoundFloor);
	Zero(f_ChainSawhuddelay);
	Zero(f_AttackDelayChainsaw);
	Zero(f_ChainsawLoopSound);
}

bool IsChainSaw(int Index)
{
	if(Index == WEAPON_CHAINSAW)
		return true;

	return false;
}
public void Enable_Chainsaw(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if (h_TimerChainSawWeaponManagement[client] != null)
	{
		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_CHAINSAW)
		{
			//BarneyItem[client] = Items_HasNamedItem(client, "Corrupted Barney's Chainsaw");
			//Is the weapon it again?
			//Yes?
			delete h_TimerChainSawWeaponManagement[client];
			h_TimerChainSawWeaponManagement[client] = null;
			DataPack pack;
			h_TimerChainSawWeaponManagement[client] = CreateDataTimer(0.1, Timer_Management_ChainSaw, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
			SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", FAR_FUTURE);
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_CHAINSAW)
	{
	//	BarneyItem[client] = Items_HasNamedItem(client, "Corrupted Barney's Chainsaw");
		DataPack pack;
		h_TimerChainSawWeaponManagement[client] = CreateDataTimer(0.1, Timer_Management_ChainSaw, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
		SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", FAR_FUTURE);
	}
}

public void Npc_OnTakeDamage_Chainsaw(int client, int damagetype)
{
	if(damagetype & DMG_CLUB) //Only count the usual melee only etc etc etc. 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetURandomInt() % sizeof(g_MeleeHitSounds)], client, SNDCHAN_AUTO, 70, _, 0.55, GetRandomInt(95,105));
	}
}

public void Weapon_ChainSawAttack(int client, int weapon, bool crit, int slot)
{
	SDKUnhook(client, SDKHook_PostThink, Chainsaw_ability_Prethink);
	SDKHook(client, SDKHook_PostThink, Chainsaw_ability_Prethink);
}

public void Chainsaw_ability_Prethink(int client)
{
	if(GetClientButtons(client) & IN_ATTACK)
	{
		if(f_AttackDelayChainsaw[client] > GetGameTime())
		{
			return;
		}
		int weapon_active = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(weapon_active < 0)
		{
			SDKUnhook(client, SDKHook_PostThink, Chainsaw_ability_Prethink);
			return;
		}
		if(!IsChainSaw(i_CustomWeaponEquipLogic[weapon_active]))
		{
			SDKUnhook(client, SDKHook_PostThink, Chainsaw_ability_Prethink);
			return;
		}
		float Getspeed = Attributes_Get(weapon_active, 6, 1.0);
		/*
		if(LastMann)
			Getspeed *= 0.5;
		*/
		f_AttackDelayChainsaw[client] = GetGameTime() + (1.0 * Getspeed);
		Chainsaw_SawAttack(client, weapon_active);
	}
	else
	{
		SDKUnhook(client, SDKHook_PostThink, Chainsaw_ability_Prethink);
		return;
	}
}

public void Chainsaw_SawAttack(int client, int weapon)
{
	bool result;
	//attack!
	int new_ammo = GetAmmo(client, 9);
	if(new_ammo <= 1)
	{
		return;
	}
	TF2_CalcIsAttackCritical(client, weapon, "", result);
}

void EmitSoundChainsaw(int client, int sound)
{
	if(sound == 1)
	{
		EmitSoundToAll(g_MeleeAttack[GetURandomInt() % sizeof(g_MeleeAttack)], client, SNDCHAN_AUTO, 70, _, 0.3, GetRandomInt(95,105));
	}
	else
	{
		EmitSoundToAll(g_MeleeHitSoundFloor[GetURandomInt() % sizeof(g_MeleeHitSoundFloor)], client, SNDCHAN_AUTO, 70, _, 0.3, GetRandomInt(95,105));
	}
}

public Action Timer_Management_ChainSaw(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		if(IsValidClient(client))
			ChainsawCancelSound(client);

		h_TimerChainSawWeaponManagement[client] = null;
		return Plugin_Stop;
	}	

	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
	{
		ChainSawHudShow(client);
	}
	else
	{
		ChainsawCancelSound(client);
	}
	return Plugin_Continue;
}

void ChainSawHudShow(int client)
{
	if(f_ChainSawhuddelay[client] < GetGameTime())
	{
		f_ChainSawhuddelay[client] = GetGameTime() + 0.5;
	}
	if(f_ChainsawLoopSound[client] < GetGameTime())
	{
		int new_ammo = GetAmmo(client, 9);
		if(new_ammo < 3)
		{
			ChainsawCancelSound(client);
			return;
		}
		EmitCustomToAll("zombie_riot/sawrunner/chainsaw_loop.mp3", client, SNDCHAN_AUTO, 70, _, 0.3, 100);
		f_ChainsawPlaySound[client] = true;
		f_ChainsawLoopSound[client] = GetGameTime() + 2.9;
	}
}

void ChainsawCancelSound(int client)
{
	if(f_ChainsawPlaySound[client])
		StopSound(client, SNDCHAN_AUTO, "zombie_riot/sawrunner/chainsaw_loop.mp3");

	f_ChainSawhuddelay[client] = 0.0;
	f_ChainsawLoopSound[client] = 0.0;
	f_ChainsawPlaySound[client] = false;
}