#pragma semicolon 1
#pragma newdecls required

public void Reload_Five_Seven(int client, int weapon, const char[] classname)
{
	PrintToChatAll("test");
	SetEntProp(weapon, Prop_Data, "m_iClip1", 24);
}


