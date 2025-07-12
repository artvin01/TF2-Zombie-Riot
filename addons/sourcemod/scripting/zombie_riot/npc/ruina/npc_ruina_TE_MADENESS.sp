#pragma semicolon 1
#pragma newdecls required


static char g_HurtSounds[][] = {
	")vo/medic_painsharp01.mp3",
	")vo/medic_painsharp02.mp3",
	")vo/medic_painsharp03.mp3",
	")vo/medic_painsharp04.mp3",
	")vo/medic_painsharp05.mp3",
	")vo/medic_painsharp06.mp3",
	")vo/medic_painsharp07.mp3",
	")vo/medic_painsharp08.mp3",
};

static char g_DeathSounds[][] = {
	"vo/medic_paincrticialdeath01.mp3",
	"vo/medic_paincrticialdeath02.mp3",
	"vo/medic_paincrticialdeath03.mp3",
};

static char g_charge_sound[][] = {
	"vo/medic_laughshort01.mp3",
	"vo/medic_laughshort02.mp3",
	"vo/medic_laughshort03.mp3",
};

static char g_IdleAlertedSounds[][] = {
	"vo/medic_battlecry01.mp3",
	"vo/medic_battlecry02.mp3",
	"vo/medic_battlecry03.mp3",
	"vo/medic_battlecry04.mp3",
};
static char g_MeleeHitSounds[][] = {
	"weapons/halloween_boss/knight_axe_hit.wav",
};

static bool TE_Madness_Used[MAXENTITIES]={false,...};
static float TE_Madness_BEAM_LOC[MAXENTITIES][2][50][3];	//how funny this will be.
static float TE_Madness_END_BEAM_LOC[MAXENTITIES][2][50][3];	//how funny this will be.

static char gLaser1;
static char gExplosive1;

public void Adiantum_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_charge_sound)); i++) { PrecacheSound(g_charge_sound[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_DeathSounds));	i++) { PrecacheSound(g_DeathSounds[i]);	}
	
	gLaser1 = PrecacheModel("materials/sprites/laserbeam.vmt");
	
	PrecacheSound("misc/halloween/gotohell.wav");
}


methodmap Adiantum < CClotBody
{
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(4.0, 7.0);
		
		
	}
	
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(80, 85));
		
		
	}
	public void PlayChargeSound() {
		EmitSoundToAll(g_charge_sound[GetRandomInt(0, sizeof(g_charge_sound) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(80, 85));
		
		
	}
	public void PlayDeathSound() {
		
		int sound = GetRandomInt(0, sizeof(g_DeathSounds) - 1);
		
		EmitSoundToAll(g_DeathSounds[sound], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(80, 85));
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		
		
	}
	public Adiantum(float vecPos[3], float vecAng[3], int ally)
	{
		Adiantum npc = view_as<Adiantum>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.0", "13500", ally));
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		i_NpcInternalId[npc.index] = RUINA_ADIANTUM;
		
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;		
		
		npc.m_flNextMeleeAttack = 0.0;
		
		
		SDKHook(npc.index, SDKHook_OnTakeDamage, Adiantum_ClotDamaged);
		SDKHook(npc.index, SDKHook_Think, Adiantum_ClotThink);				
		
		
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		
		
		
		int skin = 5;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/player/items/medic/medic_zombie.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 1);
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/weapons/c_models/c_demo_sultan_sword/c_demo_sultan_sword.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/medic/sbxo2014_medic_wintergarb_coat/sbxo2014_medic_wintergarb_coat.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/medic/Xms2013_Medic_Robe/Xms2013_Medic_Robe.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/medic/Xms2013_Medic_Hood/Xms2013_Medic_Hood.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");
		
		SetEntityRenderColor(npc.index, 255, 255, 255, 255);
		
		SetEntityRenderColor(npc.m_iWearable5, 7, 255, 255, 255);
		
		SetEntityRenderColor(npc.m_iWearable4, 7, 255, 255, 255);
		
		SetEntityRenderColor(npc.m_iWearable3, 7, 255, 255, 255);
		
		SetEntityRenderColor(npc.m_iWearable2, 7, 255, 255, 255);
		
		SetEntityRenderColor(npc.m_iWearable1, 7, 255, 255, 255);
		
		
		Ruina_Set_Heirarchy(npc.index, RUINA_RANGED_NPC);	//is a ranged npc
		
		npc.m_flSpeed = 0.0;
		
		npc.m_flCharge_Duration = 0.0;
		npc.m_flCharge_delay = GetGameTime(npc.index) + 2.0;
		npc.StartPathing();
		
		TE_Madness_Used[npc.index]=false;
		return npc;
	}
	
	
}


public void Adiantum_ClotThink(int iNPC)
{
	Adiantum npc = view_as<Adiantum>(iNPC);
	
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();	
		
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST");
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + 1.0;
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
			float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
			
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
			
			Ruina_Ai_Override_Core(npc.index, PrimaryThreatIndex);	//handles movement
			
			if(!TE_Madness_Used[npc.index])
			{
				TE_Madness(npc.index, PrimaryThreatIndex);
				TE_Madness_Used[npc.index]=true;
			}
			if(flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED || npc.m_flAttackHappenswillhappen)
			{
				//Look at target so we hit.
			//	npc.FaceTowards(vecTarget, 1000.0);
				
				//Can we attack right now?
				if(npc.m_flNextMeleeAttack < GetGameTime(npc.index))
				{
					//Play attack ani
					if (!npc.m_flAttackHappenswillhappen)
					{
						npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_ALLCLASS");
						npc.m_flAttackHappens = GetGameTime(npc.index)+0.4;
						npc.m_flAttackHappens_bullshit = GetGameTime(npc.index)+0.54;
						npc.m_flAttackHappenswillhappen = true;
					}
						
					if (npc.m_flAttackHappens < GetGameTime(npc.index) && npc.m_flAttackHappens_bullshit >= GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
					{
						Handle swingTrace;
						npc.FaceTowards(vecTarget, 20000.0);
						if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex))
						{
							int target = TR_GetEntityIndex(swingTrace);	
							
							float vecHit[3];
							TR_GetEndPosition(vecHit, swingTrace);
							
							if(target > 0) 
							{
								float dmg = 30.0;
								if(Waves_GetRoundScale()>40)
								{
									dmg=50.0;
								}
								if(target <= MaxClients)
									SDKHooks_TakeDamage(target, npc.index, npc.index, dmg, DMG_CLUB, -1, _, vecHit);
								else
									SDKHooks_TakeDamage(target, npc.index, npc.index, dmg*1.25, DMG_CLUB, -1, _, vecHit);
								
								
								
								
								// Hit sound
								npc.PlayMeleeHitSound();
								
							} 
						}
						delete swingTrace;
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.8;
						npc.m_flAttackHappenswillhappen = false;
					}
					else if (npc.m_flAttackHappens_bullshit < GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
					{
						npc.m_flAttackHappenswillhappen = false;
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.8;
					}
				}
			}
			else
			{
				npc.StartPathing();
				
			}
	}
	else
	{
		npc.StopPathing();
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public void TE_Madness(int ref, int enemy)
{
	int entity = EntRefToEntIndex(ref);
	if(IsValidEntity(entity))
	{
		SDKHook(ref, SDKHook_Think, TE_Madness_Primary_TBB_Tick);
		CreateTimer(60.0, TE_Madness_TBB_Timer, ref, TIMER_FLAG_NO_MAPCHANGE);
	}
}
static bool TE_Madness_Stop[MAXENTITIES]={false,...};
/*
public Action TE_Madness_Secondary_TBB_Tick(int client)
{
	Adiantum npc = view_as<Adiantum>(client);
	if(!IsValidEntity(client) || TE_Madness_Stop[npc.index])
	{
		SDKUnhook(client, SDKHook_Think, TE_Madness_Secondary_TBB_Tick);
		TE_Madness_Stop[npc.index]=false;
	}
	int red=255, green=255, blue=255, alpha=100;
	int testing=12;
	float radius=25;
	int CustomAng;
	
	float origin[3];
	
	float tempAngles[3];
	int colour[4];
	colour[0]=red;
	colour[1]=green;
	colour[2]=blue;
	colour[3]=alpha;
	
	float fAng[3], fPos[3];
	GetClientEyeAngles(client, fAng);
	GetClientEyePosition(client, fPos);
	
	fPos[2]+=50.0;
	
	float Direction[3];
	
	tempAngles[1]=fAng[1]*-1;
	GetAngleVectors(tempAngles, Direction, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(Direction, radius);
	AddVectors(fPos, Direction, origin);
	
	int SPRITE_INT_2 = PrecacheModel("materials/sprites/lgtning.vmt", false);
	TE_SetupBeamPoints(origin, fPos, SPRITE_INT_2, 0, 0, 0, 0.1, 22.0, 10.2, 1, 0.1, colour, 0);
	TE_SendToAll();
	
	return Plugin_Continue;
}
*/
static float TE_Madness_Angle[MAXENTITIES];
static float TE_Madness_TE_Throttle[MAXENTITIES];
static float TE_Madness_Attack_Timer[MAXENTITIES][50];
static bool TE_Madness_Inverted[MAXENTITIES]={false,...};

public Action TE_Madness_Primary_TBB_Tick(int client)
{
	Adiantum npc = view_as<Adiantum>(client);
	if(!IsValidEntity(client) || TE_Madness_Stop[npc.index])
	{
		SDKUnhook(client, SDKHook_Think, TE_Madness_Primary_TBB_Tick);
		TE_Madness_Stop[npc.index]=false;
	}
	float UserLoc[3];
	int red=255, green=255, blue=255, alpha=100;
	int testing=12;
	float radius;
	int CustomAng;
	
	float origin[3];
	
	int colour[4];
	colour[0]=red;
	colour[1]=green;
	colour[2]=blue;
	colour[3]=alpha;
	
	float UserAng[3];
	
	if(TE_Madness_TE_Throttle[client]>1.75)
	{
		TE_Madness_TE_Throttle[client]-=1.5;
		for(int o=0 ; o<=1 ; o++)
		{
			switch(o)
			{
				case 0:
				{			
					GetAbsOrigin(client, UserLoc);
					CustomAng=-1;
					radius=200.0;
					UserLoc[2]+=500.0;
					TE_Madness_Inverted[client]=true;
				}
				case 1:
				{
					GetAbsOrigin(client, UserLoc);
					CustomAng=1;
					radius=50.0;
					UserLoc[2]+=10.0;
					TE_Madness_Inverted[client]=false;
				}
			}
			UserAng[0] = 0.0;
			UserAng[1] = TE_Madness_Angle[client];
			UserAng[2] = 0.0;
						
			float tempAngles[3], Direction[3];
			tempAngles[1] = UserAng[1];
						
			TE_Madness_Angle[client] += 0.5;
						
			if (TE_Madness_Angle[client] >= 360.0)
			{
					TE_Madness_Angle[client] = 0.0;
			}
			
			origin[0]=UserLoc[0];
			origin[1]=UserLoc[1];
			origin[2]=UserLoc[2];
			
			spawnRing_Vector(UserLoc, radius*2, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", red, green, blue, alpha, 1, 0.1, 2.5, 0.1, 1);
				
			testing*=2;
				
			for(int j=1 ; j <= testing ; j++)	//generate petal start points
			{
				tempAngles[1] = CustomAng*(UserAng[1]+(360/testing)*float(j));
				GetAngleVectors(tempAngles, Direction, NULL_VECTOR, NULL_VECTOR);
				ScaleVector(Direction, radius);
				AddVectors(origin, Direction, TE_Madness_BEAM_LOC[npc.index][o][j]);
			}
			TE_Madness_BEAM_LOC[npc.index][o][testing+1][0]=TE_Madness_BEAM_LOC[npc.index][o][1][0];
			TE_Madness_BEAM_LOC[npc.index][o][testing+1][1]=TE_Madness_BEAM_LOC[npc.index][o][1][1];
			TE_Madness_BEAM_LOC[npc.index][o][testing+1][2]=TE_Madness_BEAM_LOC[npc.index][o][1][2];
				
			testing/=2;
			radius*=3;
			for(int m=1 ; m <= testing ; m++)	//Generate petal end point
			{
				tempAngles[1] = CustomAng*(UserAng[1]+(360/testing/2)*float(m*2));
				GetAngleVectors(tempAngles, Direction, NULL_VECTOR, NULL_VECTOR);
				ScaleVector(Direction, radius);
				AddVectors(origin, Direction, TE_Madness_END_BEAM_LOC[npc.index][o][m]);
				switch(o)
				{
					case 0:
					{
						TE_Madness_END_BEAM_LOC[npc.index][0][m][2]-=200.0;
					}
					case 1:
					{
						TE_Madness_END_BEAM_LOC[npc.index][1][m][2]+=30.0;
					}
				}
			}
			TE_Madness_spawn_beams(client, colour, o);
		}
	}
	TE_Madness_TE_Throttle[client]++;
	return Plugin_Continue;
}
void TE_Madness_spawn_beams(int client, int colour[4], int o)
{
	int testing=12, y=0;
	Adiantum npc = view_as<Adiantum>(client);
	for(int m=1; m<= testing ; m++)
	{
		int x=0;
		for(int j=1; j<= 2 ; j++)
		{
			if(TE_Madness_Attack_Timer[npc.index][m]<GetGameTime(npc.index))
			{
				int PrimaryThreatIndex = npc.m_iTarget;
				float vecTarget[3];
				WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
				TE_Madness_Attack_Timer[npc.index][m]=GetGameTime(npc.index)+GetRandomFloat(15.0, 5.0);
				
				int SPRITE_INT_2 = PrecacheModel("materials/sprites/lgtning.vmt", false);
				
				TE_SetupBeamPoints(TE_Madness_END_BEAM_LOC[npc.index][1][m], TE_Madness_END_BEAM_LOC[npc.index][0][m], SPRITE_INT_2, 0, 0, 0, 0.1, 22.0, 10.2, 1, 0.1, colour, 0);
				TE_SendToAll();
				TE_Madness_Attack(vecTarget, m, client, colour);
			}
			TE_SetupBeamPoints(TE_Madness_BEAM_LOC[npc.index][o][j+x+y], TE_Madness_END_BEAM_LOC[npc.index][o][m], gLaser1, 0, 0, 0, 0.1, 1.0, 1.0, 0, 0.05, colour, 1);
			TE_SendToAll();
			x++;
		}
		y+=2;
	}
}
public void TE_Madness_Attack(float vecTarget[3], int m, int client, int colour[4])
{
	Adiantum npc = view_as<Adiantum>(client);

	EmitSoundToAll("misc/halloween/gotohell.wav", 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vecTarget);
	
	float Range=50.0;
	float Dmg=50.0;
	
	Handle data;
	CreateDataTimer(0.5, Smite_Timer_TE_Madness, data, TIMER_FLAG_NO_MAPCHANGE);
	WritePackFloat(data, vecTarget[0]);
	WritePackFloat(data, vecTarget[1]);
	WritePackFloat(data, vecTarget[2]);
	WritePackCell(data, m); // mmmmmmmm microwave
	WritePackFloat(data, Range); // Range
	WritePackFloat(data, Dmg); // Damge
	WritePackCell(data, client);
}
public Action Smite_Timer_TE_Madness(Handle Smite_Logic, DataPack data)
{
	ResetPack(data);
		
	float vecTarget[3];
	vecTarget[0] = ReadPackFloat(data);
	vecTarget[1] = ReadPackFloat(data);
	vecTarget[2] = ReadPackFloat(data);
	int m = ReadPackCell(data);
	float Ionrange = ReadPackFloat(data);
	float Iondamage = ReadPackFloat(data);
	int client = EntRefToEntIndex(ReadPackCell(data));
	
	Adiantum npc = view_as<Adiantum>(client);
	
	if (!IsValidEntity(client))
	{
		return Plugin_Stop;
	}
	int colour[4];
	colour[0]=100;
	colour[1]=50;
	colour[2]=255;
	colour[3]=100;
	
	TE_SetupBeamPoints(vecTarget, TE_Madness_END_BEAM_LOC[npc.index][0][m], gLaser1, 0, 0, 0, 0.1, 15.0, 15.0, 0, 1.0, colour, 1);
	TE_SendToAll();
	
	Explode_Logic_Custom(Iondamage, client, client, -1, vecTarget, Ionrange , _ , _ , true);
	
	TE_SetupExplosion(vecTarget, gExplosive1, 10.0, 1, 0, 0, 0);
	TE_SendToAll();
	EmitSoundToAll("ambient/explosions/explode_9.wav", 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vecTarget);
	return Plugin_Continue;
}
public Action TE_Madness_TBB_Timer(Handle timer, int client)
{
	Adiantum npc = view_as<Adiantum>(client);
	if(!IsValidEntity(client))
		return Plugin_Continue;

	TE_Madness_Stop[npc.index]=true;
	
	return Plugin_Continue;
}
static void spawnRing_Vector(float center[3], float range, float modif_X, float modif_Y, float modif_Z, char sprite[255], int r, int g, int b, int alpha, int fps, float life, float width, float amp, int speed, float endRange = -69.0) //Spawns a TE beam ring at a client's/entity's location
{
	center[0] += modif_X;
	center[1] += modif_Y;
	center[2] += modif_Z;
	
	int ICE_INT = PrecacheModel(sprite);
	
	int color[4];
	color[0] = r;
	color[1] = g;
	color[2] = b;
	color[3] = alpha;
	
	if (endRange == -69.0)
	{
		endRange = range + 0.5;
	}
	
	TE_SetupBeamRingPoint(center, range, endRange, ICE_INT, ICE_INT, 0, fps, life, width, amp, color, speed, 0);
	TE_SendToAll();
}
public Action Adiantum_ClotDamaged(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
	Adiantum npc = view_as<Adiantum>(victim);
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void Adiantum_NPCDeath(int entity)
{
	Adiantum npc = view_as<Adiantum>(entity);
	
	npc.PlayDeathSound();
	
	SDKUnhook(npc.index, SDKHook_OnTakeDamage, Adiantum_ClotDamaged);
	SDKUnhook(npc.index, SDKHook_Think, Adiantum_ClotThink);	
		
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
}




	
	