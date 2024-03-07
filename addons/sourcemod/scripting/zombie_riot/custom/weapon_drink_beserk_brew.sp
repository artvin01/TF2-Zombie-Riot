#pragma semicolon 1
#pragma newdecls required

static Handle Give_brew_back[MAXPLAYERS+1];
static bool Brew_up[MAXPLAYERS+1]={false, ...};

public void Weapon_Beserk_Brew(int client, int weapon, const char[] classname, bool &result)
{
	if(weapon >= MaxClients)
	{
		if(CurrentAmmo[client][Ammo_Potion_Supply] >= 1)
		{
			Give_brew_back[client] = CreateTimer(60.0, Give_Back_Berserk_Brew, EntIndexToEntRef(client), TIMER_FLAG_NO_MAPCHANGE);
			CreateTimer(60.0, Give_Back_Brew_Restore_Ammo, client, TIMER_FLAG_NO_MAPCHANGE);
			if(Brew_up[client])
			{
				delete Give_brew_back[client];
			}
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "You are a GOD!");
			SetAmmo(client, Ammo_Potion_Supply, 0); //Give ammo back that they just spend like an idiot
			CurrentAmmo[client][Ammo_Potion_Supply] = GetAmmo(client, Ammo_Potion_Supply);
			Brew_up[client] = true;
			Beserk_Mode_Stats(client);
			float Beserk_Loc[3];
			GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", Beserk_Loc);
			ParticleEffectAt(Beserk_Loc, "fireSmokeExplosion", 1.5);
			f_TempCooldownForVisualManaPotions[client] = GetGameTime() + 60.0;
				
			EmitSoundToAll("player/pl_scout_dodge_can_drink.wav", client, SNDCHAN_STATIC, 80, _, 1.0);
		}
		else
		{
			float Ability_CD = f_TempCooldownForVisualManaPotions[client] - GetGameTime();
		
			if(Ability_CD <= 0.0)
				Ability_CD = 0.0;
			
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
		}
	}
}

public void Beserk_Brew_MapStart()
{
	PrecacheSound("player/pl_scout_dodge_can_drink.wav");
	Zero(Brew_up);
}
public void Beserk_Mode_Stats(int client)
{
	ApplyTempAttrib(client, 2, 1.2, 8.0);
	ApplyTempAttrib(client, 6, 0.8, 8.0);
	ApplyTempAttrib(client, 97, 0.75, 8.0);
	ApplyTempAttrib(client, 107, 1.25, 8.0);
	ApplyTempAttrib(client, 405, 1.33, 8.0);
	TF2_AddCondition(client, TFCond_HalloweenQuickHeal, 3.0, client);
	TF2_AddCondition(client, TFCond_UberchargedOnTakeDamage	, 0.5, client);
	CreateTimer(8.0, After_Beserk_Mode_Stats, client, TIMER_FLAG_NO_MAPCHANGE);
}

public Action After_Beserk_Mode_Stats(Handle cut_timer, int client)
{
	ApplyTempAttrib(client, 412, 1.25, 5.0);
	ApplyTempAttrib(client, 6, 1.2, 5.0);
	ApplyTempAttrib(client, 97, 1.25, 5.0);
	ApplyTempAttrib(client, 107, 0.75, 5.0);
	ApplyTempAttrib(client, 405, 0.67, 5.0);
	TF2_AddCondition(client, TFCond_Dazed, 5.0, client);
}

public void Reset_stats_Beserk_Singular(int client)
{
	Brew_up[client] = false;
}
public Action Give_Back_Brew_Restore_Ammo(Handle cut_timer, int client)
{
	if(!IsValidClient(client))
		CurrentAmmo[client][Ammo_Potion_Supply] = 1;
		
	return Plugin_Handled;
}
public Action Give_Back_Berserk_Brew(Handle cut_timer, int ref)
{
	int client = EntRefToEntIndex(ref);
	if (IsValidClient(client))
	{
		//	ClientCommand(client, "playgamesound items/ammo_pickup.wav");
		//	ClientCommand(client, "playgamesound items/ammo_pickup.wav");
		SetAmmo(client, Ammo_Potion_Supply, 1); //Give ammo back that they just spend like an idiot
		CurrentAmmo[client][Ammo_Potion_Supply] = GetAmmo(client, Ammo_Potion_Supply);
		ClientCommand(client, "playgamesound items/gunpickup2.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Mana Regen Potion Back");
		Brew_up[client] = false;
	}
	return Plugin_Handled;
}
