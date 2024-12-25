#pragma semicolon 1
#pragma newdecls required


//This is shield charges
Handle GlobalShieldTimer;
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
	ShieldLogicRegen(1);
	if (GlobalShieldTimer != null)
	{
		delete GlobalShieldTimer;
	}
	GlobalShieldTimer = null;
}

int i_MalfunctionShield[MAXENTITIES]; 
bool OnTakeDamage_ShieldLogic(int victim, int damagetype)
{
	float DodgeChance = 1.0;
	// 0.0 means guranteed dodge
	if(!CheckInHud())
	{
		if(damagetype & (DMG_CLUB|DMG_TRUEDAMAGE))
		{
			
		}
		else
		{
			if(b_ElasticFlyingCape) //10% dodge chance
			{
				DodgeChance *= 0.9;
			}
		}
		
		if(b_BraceletsOfAgility) //10% dodge chance
		{
			DodgeChance *= 0.9;
		}
		if(DodgeChance != 1.0 && GetRandomFloat(0.0,1.0) > DodgeChance)
		{
			float chargerPos[3];
			GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", chargerPos);
			chargerPos[2] += 82.0;
			TE_ParticleInt(g_particleMissText, chargerPos);
			TE_SendToAll();
			return true;
		}
	}
	
	if(b_MalfunctionShield)
	{
		if(i_MalfunctionShield[victim] > 0)
		{
			if(!CheckInHud())
			{
				ShieldBlockEffect(victim);
				i_MalfunctionShield[victim] -= 1;
			}
			return true;
		}
	}
	return false;
}

public void AnyShieldOnObtained()
{
	if (GlobalShieldTimer != INVALID_HANDLE)
		return;

	GlobalShieldTimer = CreateTimer(10.0, ShieldRegenTimer,_,TIMER_REPEAT);
}
public Action ShieldRegenTimer(Handle timer, int client)
{
	bool AnyShieldThere = false;
	if(b_MalfunctionShield)
	{
		AnyShieldThere = true;
		ShieldLogicRegen(1);
	}
	if(!AnyShieldThere)
	{
		GlobalShieldTimer = null;
		return Plugin_Stop;
	}
	return Plugin_Continue;
}
void ShieldLogicRegen(int Type)
{
    for(int client=1; client<MAXENTITIES; client++)
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
	if(client > MaxClients)
		return;
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