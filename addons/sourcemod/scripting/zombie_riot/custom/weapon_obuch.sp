#pragma semicolon 1
#pragma newdecls required
static int i_swinged[MAXTF2PLAYERS];
static float f_rest_time[MAXTF2PLAYERS];

#define OBUCH_MAX_DMG 1.25
#define OBUCH_MAX_SPEED 0.75
#define OBUCH_MAX_SWING 60

public void Obuch_Mapstart()
{
	Zero(f_rest_time);
	Zero(i_swinged);
	ObuchHammer_Map_Precache();
}
void ObuchHammer_Map_Precache() //Anything that needs to be precaced like sounds or something.
{
	PrecacheSound("weapons/bat_baseball_hit_flesh.wav");
}

/*
public void Npc_OnTakeDamage_ObuchHammer(int attacker, int weapon)
{

	ApplyTempAttrib(weapon, 6, 0.7, 1.2);
	ApplyTempAttrib(weapon, 2, 1.1, 1.2);
	ApplyTempAttrib(weapon, 206, 0.95, 1.2);
	PrintToChatAll("Hit");
	
}
*/

public void Npc_OnTakeDamage_ObuchHammer(int attacker, int weapon)
{
	float damage = Attributes_Get(weapon, 2, 1.0);
	damage *= Attributes_Get(weapon, 1, 1.0);
	float swingspeed = Attributes_Get(weapon, 6, 1.0);
	swingspeed *= Attributes_Get(weapon, 5, 1.0);

	EmitSoundToAll("weapons/bat_baseball_hit_flesh.wav", attacker, SNDCHAN_STATIC, 80, _, 0.9, 120);
	float GameTime = GetGameTime();

	i_swinged[attacker] += 1;

	if(f_rest_time[attacker] < GameTime)
	{
		i_swinged[attacker]=0;
		Attributes_Set(weapon, 6, 2.5);
	}
	else
	{
		float ratio =  1 + float(i_swinged[attacker])/OBUCH_MAX_SWING;

		if(ratio>=OBUCH_MAX_DMG)
		{
			damage*=OBUCH_MAX_DMG;
			//swingspeed *= OBUCH_MAX_SPEED;
			Attributes_Set(weapon, 6, OBUCH_MAX_SPEED);
			PrintToChatAll("MAX POWER");
		}
		else
		{
			damage*=ratio;
			swingspeed*=1.125/ratio;
			Attributes_Set(weapon, 6, swingspeed);
			PrintToChatAll("CHARGING");
		}
	}

	f_rest_time[attacker] = GameTime + 1.50;

}

/*
public void Melee_ObuchTouch(int entity, int target)
{
	int particle = EntRefToEntIndex(i_WandParticle[entity]);
	if (target > 0)	
	{
		//Code to do damage position and ragdolls
		static float angles[3];
		GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);
		float vecForward[3];
		GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
		static float Entity_Position[3];
		WorldSpaceCenter(target, Entity_Position);

		int owner = EntRefToEntIndex(i_WandOwner[entity]);
		int weapon = EntRefToEntIndex(i_WandWeapon[entity]);

		float Dmg_Force[3]; CalculateDamageForce(vecForward, 10000.0, Dmg_Force);
		SDKHooks_TakeDamage(target, entity, owner, f_WandDamage[entity], DMG_CLUB, weapon, Dmg_Force, Entity_Position);	// 2048 is DMG_NOGIB?

		ApplyTempAttrib(weapon, 6, 0.8, 0.1);
		ApplyTempAttrib(weapon, 2, 1.1, 0.1);

		EmitSoundToAll(SOUND_AUTOAIM_IMPACT_FLESH_1, entity, SNDCHAN_STATIC, 80, _, 0.9, 120);

		RemoveEntity(entity);
	}
}
*/