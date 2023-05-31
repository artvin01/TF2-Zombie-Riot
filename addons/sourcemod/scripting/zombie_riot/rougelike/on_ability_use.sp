
float f_WrathOfItallians[MAXENTITIES];


void Rouge_OnAbilityUseMapStart()
{
	Zero(f_WrathOfItallians);
}
void Rouge_OnAbilityUse(int client, int weapon)
{
	if(b_WrathOfItallians)
	{
		f_WrathOfItallians[weapon] = GetGameTime() + 1.0;
	}
}

bool Rouge_InItallianWrath(int weapon)
{
	if(weapon < 0)
		return false;

	if(f_WrathOfItallians[weapon] > GetGameTime())
		return true;

	return false;
}