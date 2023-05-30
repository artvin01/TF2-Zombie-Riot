
//This is shield charges
void ShieldLogic_OnMapStart()
{
	PrecacheSound("player/resistance_light1.wav", true);
	PrecacheSound("player/resistance_light2.wav", true);
	PrecacheSound("player/resistance_light3.wav", true);
	PrecacheSound("player/resistance_light4.wav", true);
	PrecacheSound("player/resistance_medium1.wav", true);
	PrecacheSound("player/resistance_medium2.wav", true);
	PrecacheSound("player/resistance_medium3.wav", true);
	PrecacheSound("player/resistance_medium4.wav", true);
	PrecacheSound("player/resistance_heavy1.wav", true);
	PrecacheSound("player/resistance_heavy2.wav", true);
	PrecacheSound("player/resistance_heavy3.wav", true);
	PrecacheSound("player/resistance_heavy4.wav", true);
	PrecacheSound("weapons/medi_shield_deploy.wav", true);
	PrecacheSound("weapons/medi_shield_retract.wav", true);
}

int i_MalfunctionShield[MAXENTITIES]; 
void OnTakeDamage_ShieldLogic(int victim, int holding_weapon)
{
    if(b_MalfunctionShield)
    {
        if(i_MalfunctionShield[victim] > 0)
        {
            ShieldBlockEffect(victim);
            i_MalfunctionShield[victim] -= 1;
            return true;
        }
    }
    return false;
}

void ShieldLogicRegen(int Type)
{
    for(int client=1; client<=MaxClients; client++)
    {
        switch(Type)
        {
            case 1:
            {
                i_MalfunctionShield[client] = 1;
            }
        }
    }
}
void ShieldBlockEffect(int client)
{
	float Injured[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", Injured);
	Injured[2] += 45.0;
	TE_Particle("spell_batball_impact_red", Injured, NULL_VECTOR, NULL_VECTOR, client, _, _, _, _, _, _, _, _, _, 0.0);
	switch(GetRandomInt(1,4))
	{
		case 1:
		{
			EmitSoundToAll("player/resistance_heavy1.wav", client,_,70);
			EmitSoundToAll("player/resistance_heavy1.wav", client,_,70);
		}
		case 2:
		{
			EmitSoundToAll("player/resistance_heavy2.wav", client,_,70);
			EmitSoundToAll("player/resistance_heavy2.wav", client,_,70);
		}
		case 3:
		{
			EmitSoundToAll("player/resistance_heavy3.wav", client,_,70);
			EmitSoundToAll("player/resistance_heavy3.wav", client,_,70);
		}
		case 4:
		{
			EmitSoundToAll("player/resistance_heavy4.wav", client,_,70);
			EmitSoundToAll("player/resistance_heavy4.wav", client,_,70);
		}
	}
}