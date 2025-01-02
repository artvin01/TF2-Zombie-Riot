#pragma semicolon 1
#pragma newdecls required


float f_WrathOfItallians[MAXENTITIES];


void Rogue_OnAbilityUseMapStart()
{
	Zero(f_WrathOfItallians);
}
void Rogue_OnAbilityUse(int client, int weapon)
{
	if(b_WrathOfItallians)
	{
		f_WrathOfItallians[weapon] = GetGameTime() + 1.0;
	}

	Rogue_ParadoxDLC_AbilityUsed(client);
}

bool Rogue_InItallianWrath(int weapon)
{
	if(weapon < 0)
		return false;

	if(f_WrathOfItallians[weapon] > GetGameTime())
		return true;

	return false;
}