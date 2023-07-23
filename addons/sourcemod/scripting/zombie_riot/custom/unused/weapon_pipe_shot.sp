#pragma semicolon 1
#pragma newdecls required

#define SPLIT_ANGLE_OFFSET 2.0

#define SOUND_PIPE_SHOOT		"weapons/bow_shoot.wav"

public void Weapon_Pipe_Shoot_Map_Precache()
{
	PrecacheSound(SOUND_PIPE_SHOOT);
}

public void Weapon_Shoot_Pipe(int client, int weapon, bool crit)
{
	float damage = 100.0;
	damage *= Attributes_Get(weapon, 2, 1.0);
		
	float fAng[3],angVelocity, fPos[3];
	GetClientEyeAngles(client, fAng);
	GetClientEyePosition(client, fPos);
	
	angVelocity = 500.0;
	/*
		1 - Bullet
	2 - Rocket
	3 - Pipebomb
	4 - Stickybomb (Stickybomb Launcher)
	5 - Syringe
	6 - Flare
	8 - Huntsman Arrow
	11 - Crusader's Crossbow Bolt
	12 - Cow Mangler Particle
	13 - Righteous Bison Particle
	14 - Stickybomb (Sticky Jumper)
	17 - Loose Cannon
	18 - Rescue Ranger Claw
	19 - Festive Huntsman Arrow
	22 - Festive Jarate
	23 - Festive Crusader's Crossbow Bolt
	24 - Self Aware Beuty Mark
	25 - Mutated Milk
	*/
	float speed = 800.0;
	int Pipe = SDKCall_CTFCreatePipe(fPos, fAng, speed, angVelocity/*angVelocity[3] ???*/, client, weapon, 3/*Projectile type*/, damage);
	if(IsValidEntity(Pipe))
	{
		SetEntPropEnt(Pipe, Prop_Send, "m_hOriginalLauncher", weapon);
		SetEntPropEnt(Pipe, Prop_Send, "m_hLauncher", weapon);
		PrintToChatAll("yay :)");
	}
}