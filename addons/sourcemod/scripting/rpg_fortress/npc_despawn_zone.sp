#pragma semicolon 1
#pragma newdecls required

void NPC_Despawn_Zone(int entity, const char[] name)
{
	if(GetTeam(entity) != TFTeam_Red)
	{
		if(StrEqual("rpg_despawn_zombie", name))
		{
			NPC_Despawn(entity);
		}
	}
}