#pragma semicolon 1
#pragma newdecls required



void OnTakeDamage_ProvokedAnger(int holding_weapon)
{
	if(!b_ProvokedAnger)
		return;
	
	if(f_ProvokedAngerCD[holding_weapon] > GetGameTime())
	{
		return;
	}
	f_ProvokedAngerCD[holding_weapon] = GetGameTime() + 0.5;
	//good but it doesnt make you oneshot the world.
	//itll go upto 2x damage at most.
	ApplyTempAttrib(holding_weapon, 2, 1.05, 5.0);
	ApplyTempAttrib(holding_weapon, 410, 1.05, 5.0);
}