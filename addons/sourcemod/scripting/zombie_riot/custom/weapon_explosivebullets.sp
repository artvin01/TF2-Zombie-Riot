#pragma semicolon 1
#pragma newdecls required

#define EXPLOSIVEBULLETS_BLAST_1	  "weapons/airstrike_small_explosion_01.wav"
#define EXPLOSIVEBULLETS_BLAST_2	  "weapons/airstrike_small_explosion_02.wav"
#define EXPLOSIVEBULLETS_BLAST_3	  "weapons/airstrike_small_explosion_03.wav"

#define EXPLOSIVEBULLETS_PARTICLE_1	"ExplosionCore_Wall"
#define EXPLOSIVEBULLETS_PARTICLE_2	"ExplosionCore_MidAir"


static int LaserSprite;

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
	LaserSprite = PrecacheModel(SPRITE_SPRITE, false);
}

public void Weapon_ExplosiveBullets(int client, int weapon, bool crit, int slot)
{
	int NumPellets = RoundToNearest(Attributes_Get(weapon, 118, 1.0));
	if (NumPellets < 1)
		return;
		
	float BaseDMG = 5.0; //lets set it to 5
	
	BaseDMG *= Attributes_Get(weapon, 2, 1.0);
		
	float Spread = 1.0;
	
	Spread *= Attributes_Get(weapon, 106, 1.0);
	
	float Radius = EXPLOSION_RADIUS; //base radius
	
	float Falloff = Attributes_Get(weapon, 117, 1.0);	//Damage falloff penalty
	
	
	float spawnLoc[3], eyePos[3], eyeAng[3], randAng[3];
			   
	GetClientEyePosition(client, eyePos);
	GetClientEyeAngles(client, eyeAng);
	
	bool Made_sound = true;
	b_LagCompNPC_ExtendBoundingBox = true;
	StartLagCompensation_Base_Boss(client);
	float amp = 0.5;
	float life = 0.1;
	float GunPos[3];
	float GunAng[3];
	GetAttachment(client, "effect_hand_R", GunPos, GunAng);
	int color[4];
	color[0] = 255;
	color[1] = 0;
	color[2] = 0;
	color[3] = 255;			
				
	for (int i = 0; i < NumPellets; i++)
	{
		randAng[0] = eyeAng[0] + GetRandomFloat(-Spread, Spread);
		randAng[1] = eyeAng[1] + GetRandomFloat(-Spread, Spread);
		randAng[2] = eyeAng[2] + GetRandomFloat(-Spread, Spread);
		
		Handle trace = TR_TraceRayFilterEx(eyePos, randAng, MASK_SHOT, RayType_Infinite, BulletAndMeleeTrace, client);
		if (TR_DidHit(trace))
		{
			TR_GetEndPosition(spawnLoc, trace);
		} 
		delete trace;
		
		Explode_Logic_Custom(BaseDMG, client, client, weapon, spawnLoc, Radius, Falloff);
		
		TE_SetupBeamPoints(GunPos, spawnLoc, LaserSprite, 0, 0, 0, life, 1.0, 2.2, 1, amp, color, 0);
		TE_SendToAll();
		//ExplosiveBullets_SpawnExplosion(spawnLoc);
		DataPack pack_boom = new DataPack();
		pack_boom.WriteFloat(spawnLoc[0]);
		pack_boom.WriteFloat(spawnLoc[1]);
		pack_boom.WriteFloat(spawnLoc[2]);
		pack_boom.WriteCell(0);
		RequestFrame(MakeExplosionFrameLater, pack_boom);
		
		if(Made_sound)
		{
			EmitAmbientSound(ExplosiveBullets_SFX[GetRandomInt(0, 2)], spawnLoc, _, 75, _,0.7, GetRandomInt(75, 110));
		}
		else
		{
			EmitAmbientSound(ExplosiveBullets_SFX[GetRandomInt(0, 2)], spawnLoc, _, 75, _, 0.3, GetRandomInt(75, 110));
		}
		Made_sound = false;
				 
	}
	FinishLagCompensation_Base_boss();
}

stock void ExplosiveBullets_SpawnExplosion(float DetLoc[3])
{
	int littleBoom = CreateEntityByName("info_particle_system");
	
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