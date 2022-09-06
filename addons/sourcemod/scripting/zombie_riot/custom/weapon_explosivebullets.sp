#define EXPLOSIVEBULLETS_BLAST_1	  "weapons/airstrike_small_explosion_01.wav"
#define EXPLOSIVEBULLETS_BLAST_2	  "weapons/airstrike_small_explosion_02.wav"
#define EXPLOSIVEBULLETS_BLAST_3	  "weapons/airstrike_small_explosion_03.wav"

#define EXPLOSIVEBULLETS_PARTICLE_1	"ExplosionCore_Wall"
#define EXPLOSIVEBULLETS_PARTICLE_2	"ExplosionCore_MidAir"

char ExplosiveBullets_SFX[3][255];
char ExplosiveBullets_Particles[2][255];
void ExplosiveBullets_Precache()
{
	PrecacheSound(EXPLOSIVEBULLETS_BLAST_1);
	PrecacheSound(EXPLOSIVEBULLETS_BLAST_2);
	PrecacheSound(EXPLOSIVEBULLETS_BLAST_3);
	ExplosiveBullets_SFX[0] = EXPLOSIVEBULLETS_BLAST_1;
	ExplosiveBullets_SFX[1] = EXPLOSIVEBULLETS_BLAST_2;
	ExplosiveBullets_SFX[2] = EXPLOSIVEBULLETS_BLAST_3;
	
	ExplosiveBullets_Particles[0] = EXPLOSIVEBULLETS_PARTICLE_1;
	ExplosiveBullets_Particles[1] = EXPLOSIVEBULLETS_PARTICLE_2;
}

public void Weapon_ExplosiveBullets(int client, int weapon, const char[] classname, bool &result)
{
	int NumPellets = RoundFloat(Attributes_FindOnWeapon(client, weapon, 2000));
	if (NumPellets < 1)
		return;
		
	float BaseDMG = Attributes_FindOnWeapon(client, weapon, 2002); //Base damage
	
	Address address = TF2Attrib_GetByDefIndex(weapon, 2);
	if(address != Address_Null)
		BaseDMG *= TF2Attrib_GetValue(address);
		
	float Spread = Attributes_FindOnWeapon(client, weapon, 36);	//Spread Penalty
	address = TF2Attrib_GetByDefIndex(weapon, 106);
	if(address != Address_Null)
		Spread *= TF2Attrib_GetValue(address);
	
	float Radius = Attributes_FindOnWeapon(client, weapon, 2001);	//Useless attribute, used in config to determine base radius
	float Falloff = Attributes_FindOnWeapon(client, weapon, 117);	//Damage falloff penalty
	
	float spawnLoc[3], eyePos[3], eyeAng[3], randAng[3];
			   
	GetClientEyePosition(client, eyePos);
	GetClientEyeAngles(client, eyeAng);
	
	for (int i = 0; i < NumPellets; i++)
	{
		randAng[0] = eyeAng[0] + GetRandomFloat(-Spread, Spread);
		randAng[1] = eyeAng[1] + GetRandomFloat(-Spread, Spread);
		randAng[2] = eyeAng[2] + GetRandomFloat(-Spread, Spread);
		
		Handle trace = TR_TraceRayFilterEx(eyePos, randAng, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);
		if (TR_DidHit(trace))
		{
			TR_GetEndPosition(spawnLoc, trace);
		} 
		CloseHandle(trace);
		
		Explode_Logic_Custom(BaseDMG, client, client, weapon, spawnLoc, Radius, Falloff);
		
		ExplosiveBullets_SpawnExplosion(spawnLoc);
		EmitAmbientSound(ExplosiveBullets_SFX[GetRandomInt(0, 2)], spawnLoc, _, _, _, _, GetRandomInt(75, 110));
	}
}

stock void ExplosiveBullets_SpawnExplosion(float DetLoc[3])
{
	new littleBoom = CreateEntityByName("info_particle_system");
	
	if (IsValidEdict(littleBoom))
	{
		TeleportEntity(littleBoom, DetLoc, NULL_VECTOR, NULL_VECTOR);
		
		DispatchKeyValue(littleBoom, "effect_name", ExplosiveBullets_Particles[GetRandomInt(0, 1)]);
		DispatchKeyValue(littleBoom, "targetname", "present");
		DispatchSpawn(littleBoom);
		ActivateEntity(littleBoom);
		AcceptEntityInput(littleBoom, "Start");
		
		CreateTimer(1.2, Timer_RemoveEntity, EntIndexToEntRef(littleBoom), TIMER_FLAG_NO_MAPCHANGE);
	}
}

/*public Action Timer_RemoveEntity(Handle removeIt, int ref)
{
	int entity = EntRefToEntIndex(ref);
	
	if (IsValidEntity(entity) && entity > MaxClients)
	{
		TeleportEntity(entity, OFF_THE_MAP, NULL_VECTOR, NULL_VECTOR);
		AcceptEntityInput(entity, "Kill");
		RemoveEntity(entity);
	}
	
	return;
}*/