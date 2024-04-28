#pragma semicolon 1
#pragma newdecls required

#define SAMURAI_SWORD_PARRY 	"weapons/samurai/tf_katana_impact_object_02.wav"

void SamuraiSword_Map_Precache()
{
	PrecacheSound(SAMURAI_SWORD_PARRY);
}

public void Weapon_SamuraiParry(int client, int weapon, bool crit, int slot)
{
	if (Ability_Check_Cooldown(client, slot) > 0.0)
	{
		float Ability_CD = Ability_Check_Cooldown(client, slot);
		
		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;
			
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
		return;	
	}
	int StatsForCalcMultiAdd;
	Stats_Endurance(client, StatsForCalcMultiAdd);
	StatsForCalcMultiAdd /= 3;
	//get base endurance for cost
	if(i_CurrentStamina[client] < StatsForCalcMultiAdd)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%s", "Not Enough Stamina");
		return;
	}
	RPGCore_StaminaReduction(weapon, client, StatsForCalcMultiAdd);
	StatsForCalcMultiAdd = Stats_Endurance(client);
	//subtract Stamina
	Ability_Apply_Cooldown(client, slot, 3.0);
	RPGStats_GiveTempomaryStatsToItem(weapon, 4, StatsForCalcMultiAdd, 0.5);
	EmitSoundToAll(SAMURAI_SWORD_PARRY, client, _, 65, _, 0.45);
}