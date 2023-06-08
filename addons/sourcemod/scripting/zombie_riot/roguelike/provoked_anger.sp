
void OnTakeDamage_ProvokedAnger(int holding_weapon)
{
	if(!b_ProvokedAnger)
		return;
	
	ApplyTempAttrib(holding_weapon, 2, 1.05, 5.0);
	ApplyTempAttrib(holding_weapon, 410, 1.05, 5.0);
}