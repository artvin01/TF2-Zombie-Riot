#pragma semicolon 1
#pragma newdecls required

//this thing is *kinda* an npc, but also not really


static const char g_DeathSounds[][] = {
	"vo/spy_paincrticialdeath01.mp3",
	"vo/spy_paincrticialdeath02.mp3",
	"vo/spy_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/spy_painsharp01.mp3",
	"vo/spy_painsharp02.mp3",
	"vo/spy_painsharp03.mp3",
	"vo/spy_painsharp04.mp3",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/dragons_fury_shoot.wav",
};

#define STELLAR_WEAVER_THEME "#zombiesurvival/ruina/storm_weaver_test.mp3"

#define RUINA_STORM_WEAVER_MODEL "models/props_moonbase/moon_gravel_crystal_blue.mdl" //"models/props_borealis/bluebarrel001.mdl"
#define RUINA_STORM_WEAVER_HEAD_MODEL "models/props_moonbase/moon_gravel_crystal_blue.mdl" //"models/props_borealis/bluebarrel001.mdl"
#define RUINA_STORM_WEAVER_MODEL_SIZE "2.0"	//2.0
#define RUINA_STELLAR_WEAVER_SEPERATION_DISTANCE 50.0	//50.0
#define RUINA_STORM_WEAVER_LENGHT 12	//12

#define RUINA_STORM_WEAVER_NOCLIP_SPEED 35.0
#define RUINA_STORM_WEAVER_FLIGHT_SPEED 315.0

#define RUINA_DAMAGE_INSTANCES_PER_FRAME 1	//a player can only dmg the worm x times a frame, to make piercing weapons not delete him stupidly easily
#define RUINA_CANTSEE_TIMEOUT 2.5

bool b_storm_weaver_solo;
bool b_stellar_weaver_true_solo;
static bool b_storm_weaver_noclip[MAXENTITIES];
int i_storm_weaver_damage_instance[MAXTF2PLAYERS+1];
static float fl_trace_timeout[MAXENTITIES];
static float fl_recently_teleported[MAXENTITIES];
static float fl_distance_to_keep[MAXENTITIES];
static float fl_cantseetimeout[MAXENTITIES];
static float fl_teleport_time[MAXENTITIES];
//static float fl_teleporting_time[MAXENTITIES];
static int i_segment_id[MAXENTITIES][RUINA_STORM_WEAVER_LENGHT+1];
static int i_traveling_to_anchor[MAXENTITIES];
static float fl_special_invuln_timer[MAXENTITIES];
static bool b_ignore_npc[MAXENTITIES];

void Ruina_Storm_Weaver_MapStart()
{
	//beam_model = PrecacheModel(BLITZLIGHT_SPRITE);

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Stellar Weaver");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_ruina_stellar_weaver");
	data.Category = Type_Ruina;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	strcopy(data.Icon, sizeof(data.Icon), "tank"); 						//leaderboard_class_(insert the name)
	data.IconCustom = false;												//download needed?
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;						//example: MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;, forces these flags.	
	NPC_Add(data);
}
static void ClotPrecache()
{
	Zero(b_ignore_npc);
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_MeleeHitSounds);

	PrecacheSoundCustom(STELLAR_WEAVER_THEME);

	Zero2(i_segment_id);
	Zero(b_storm_weaver_noclip);

	PrecacheModel(RUINA_STORM_WEAVER_HEAD_MODEL);
	Zero(i_storm_weaver_damage_instance);
}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return Storm_Weaver(client, vecPos, vecAng, ally, data);
}

static float fl_touch_timeout[MAXENTITIES];

methodmap Storm_Weaver < CClotBody
{
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		
		
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		
	}
	
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		
	}
	
	public Storm_Weaver(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Storm_Weaver npc = view_as<Storm_Weaver>(CClotBody(vecPos, vecAng, RUINA_STORM_WEAVER_HEAD_MODEL, RUINA_STORM_WEAVER_MODEL_SIZE, "1250", ally));
		
		i_NpcWeight[npc.index] = 999;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");

		if(ally != TFTeam_Red)
		{
			//b_thisNpcIsABoss[npc.index] = true;
		}

		b_DoNotUnStuck[npc.index] = true;
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		Ruina_Set_Heirarchy(npc.index, RUINA_RANGED_NPC);

		Ruina_Set_No_Retreat(npc.index);

		fl_trace_timeout[npc.index]=0.0;

		Zero(i_storm_weaver_damage_instance);

		func_NPCDeath[npc.index] = view_as<Function>(NPC_Death);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(ClotThink);
		
		npc.m_flGetClosestTargetTime = 0.0;

		fl_special_invuln_timer[npc.index] = GetGameTime()+2.5;

		//if(StrContains(data, "anchor") != -1)
		//	i_anchor_id[npc.index] = npc.m_iState;
		
		if(!IsValidEntity(npc.m_iState))
			npc.m_iState = INVALID_ENT_REFERENCE;

		if(!IsValidEntity(RaidBossActive))
		{
			RaidBossActive = EntIndexToEntRef(npc.index);
			RaidAllowsBuildings = false;

			RaidModeTime = 999999999.0;

			MusicEnum music;
			strcopy(music.Path, sizeof(music.Path), STELLAR_WEAVER_THEME);
			music.Time = 350;
			music.Volume = 1.0;
			music.Custom = true;
			strcopy(music.Name, sizeof(music.Name), "''Servants of The Scourge'' - Theme of The Sentinels of The Devourer");
			strcopy(music.Artist, sizeof(music.Artist), "DM DOKURO");
			Music_SetRaidMusic(music);
		}

		

		//fl_cantseetimeout[npc.index]=GetGameTime()+RUINA_CANTSEE_TIMEOUT+2.5;
		fl_teleport_time[npc.index]=0.0;
		fl_recently_teleported[npc.index]=0.0;

		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;

		bool solo = StrContains(data, "solo") != -1;

		//if(solo)
			//CPrintToChatAll("solo");

		bool true_solo = StrContains(data, "solo_true") != -1;

		//if(true_solo)
			//CPrintToChatAll("solo_true");

		b_stellar_weaver_true_solo=false;
		if(true_solo)
		{
			solo=true;
			b_stellar_weaver_true_solo=true;

			int Health = Storm_Weaver_Health(npc);
			SetEntProp(npc.index, Prop_Data, "m_iHealth", Health);
			SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", Health);
		}

		if(!solo)
		{
			b_storm_weaver_solo=false;
			int Health = Storm_Weaver_Health(npc);
			SetEntProp(npc.index, Prop_Data, "m_iHealth", Health);
			SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", Health);
		}
		else
		{
			b_storm_weaver_solo=true;
		}


		i_traveling_to_anchor[npc.index]=-1;
		//now the fun part, making him ignore all collisions...

		b_NoGravity[npc.index] = true;	//Found ya!

		float npc_vec[3]; GetAbsOrigin(npc.index, npc_vec);
		npc_vec[2] += 50.0;

		TeleportEntity(npc.index, npc_vec, NULL_VECTOR, NULL_VECTOR);

		ParticleEffectAt(npc_vec, "eyeboss_death_vortex", 5.0);

		b_ignore_npc[npc.index]=true;
		int follow_id = npc.index;
		for(int i=0 ; i< RUINA_STORM_WEAVER_LENGHT ; i++)
		{
			int buffer = Storm_Weaver_Create_Tail(npc, follow_id, i);
			follow_id = buffer;
		}

		b_NoKnockbackFromSources[npc.index] = true;
		b_ThisNpcIsImmuneToNuke[npc.index] = true;

		SDKHook(npc.index, SDKHook_Touch, Storm_Weaver_Damage_Touch);
		Zero(fl_touch_timeout);

		b_storm_weaver_noclip[npc.index]=false;

		b_IgnoreAllCollisionNPC[npc.index]=true;
		b_ForceCollisionWithProjectile[npc.index]=true;

		Storm_Weaver_Delete_Collision(npc.index);
		
		return npc;
	}
	
}
static int Storm_Weaver_Create_Tail(Storm_Weaver npc, int follow_ID, int Section)
{
	float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
	float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);	//what

	int Health = GetEntProp(npc.index, Prop_Data, "m_iHealth");
	int spawn_index;

	char buffer[16];
	IntToString(follow_ID, buffer, sizeof(buffer));


	spawn_index = NPC_CreateByName("npc_ruina_stellar_weaver_middle", npc.index, pos, ang, GetTeam(npc.index), buffer);
	i_segment_id[npc.index][Section] = EntIndexToEntRef(spawn_index);
	if(spawn_index > MaxClients)
	{
		b_ignore_npc[spawn_index]=true;
		b_storm_weaver_noclip[spawn_index]=false;
		b_IgnoreAllCollisionNPC[spawn_index]=true;
		b_ForceCollisionWithProjectile[spawn_index]=true;
		NpcAddedToZombiesLeftCurrently(spawn_index, true);
		CClotBody tail = view_as<CClotBody>(spawn_index);
		tail.m_flNextRangedAttack = GetGameTime(tail.index)+1.0+(Section/10.0);
		SetEntProp(spawn_index, Prop_Data, "m_iHealth", Health);
		SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", Health);
		fl_distance_to_keep[npc.index] = RUINA_STELLAR_WEAVER_SEPERATION_DISTANCE;
	}
	return spawn_index;
}
public void Storm_Weaver_Middle_Movement(Storm_Weaver_Mid npc, float loc[3], bool Los)
{
	float vecView[3], vecFwd[3], Entity_Loc[3], vecVel[3];
	
	GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", Entity_Loc);
		
	if(npc.IsOnGround())
	{
		Entity_Loc[2] += 50.0;
		TeleportEntity(npc.index, Entity_Loc, NULL_VECTOR, NULL_VECTOR); 
	}

	MakeVectorFromPoints(Entity_Loc, loc, vecView);
	GetVectorAngles(vecView, vecView);
		
	float speed = 100.0;	//speed
	float dist2 = GetVectorDistance(Entity_Loc, loc);

	//if(dist2>(150.0))	//just force teleport in these cases
	//{
	//	TeleportEntity(npc.index, loc, NULL_VECTOR, NULL_VECTOR);
	//	return;
	//}

	if(dist2<speed)
		speed = dist2;

	if(speed<fl_distance_to_keep[npc.index])
		speed=fl_distance_to_keep[npc.index];

	GetAngleVectors(vecView, vecFwd, NULL_VECTOR, NULL_VECTOR);
		
	Entity_Loc[0]+=vecFwd[0] * speed;
	Entity_Loc[1]+=vecFwd[1] * speed;
	Entity_Loc[2]+=vecFwd[2] * speed;
			
	GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", vecFwd);
		
	SubtractVectors(Entity_Loc, vecFwd, vecVel);
	ScaleVector(vecVel, 10.0);
	vecView[0]-=90.0;
	TeleportEntity(npc.index, NULL_VECTOR, vecView, NULL_VECTOR);

	npc.SetVelocity(vecVel);

	if(Los)	//true=we cant see.
	{
		fl_cantseetimeout[npc.index] = GetGameTime() + RUINA_CANTSEE_TIMEOUT;
		if(!b_storm_weaver_noclip[npc.index])
		{
			Storm_Weaver_Delete_Collision(npc.index);
			return;
		}
	}
	if(b_storm_weaver_noclip[npc.index] && fl_cantseetimeout[npc.index] <= GetGameTime())
	{
		Storm_Weaver_Restore_Collisions(npc.index);
	}

	//if(b_storm_weaver_noclip[npc.index])	//if we are in noclip, do special stuff to detect projectiles near our location
	//{
	//	Storm_Weaver_Middle_Projectile_Logic(npc, loc);
	//}
		
}
/*static void Storm_Weaver_Middle_Projectile_Logic(Storm_Weaver_Mid npc, float loc[3])
{
	
	for(int i=MAXTF2PLAYERS ; i < MAXENTITIES ; i++)
	{
		if(!IsValidEntity(i))
			continue;

		if(b_IsAProjectile[i])
		{
			float Pro_Loc[3];
			GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", Pro_Loc);
			float Dist = GetVectorDistance(Pro_Loc, loc, true);
			if(Dist < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED)
			{

			}
		}
	}
}*/

int Storm_Weaver_Return_Health(CClotBody npc)
{
	int section = EntRefToEntIndex(npc.m_iState);
	if(IsValidEntity(section))
	{
		return GetEntProp(section, Prop_Data, "m_iHealth");
	}
	return 69420;
	
}
static void Storm_Weaver_Pulse_Solo_Mode(Storm_Weaver npc)
{
	i_GetMagiaAnchor(npc);

	if(npc.m_iState == INVALID_ENT_REFERENCE)
	{
		Storm_Weaver_Force_Spawn_Anchors(npc);
	}	

	if(npc.m_iState != INVALID_ENT_REFERENCE)
	{
		b_storm_weaver_solo=false;
	}
}
static void Storm_Weaver_Force_Spawn_Anchors(Storm_Weaver npc)
{
	float AproxRandomSpaceToWalkTo[3];

	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", AproxRandomSpaceToWalkTo);

	AproxRandomSpaceToWalkTo[2] += 50.0;

	AproxRandomSpaceToWalkTo[0] = GetRandomFloat((AproxRandomSpaceToWalkTo[0] - 800.0),(AproxRandomSpaceToWalkTo[0] + 800.0));
	AproxRandomSpaceToWalkTo[1] = GetRandomFloat((AproxRandomSpaceToWalkTo[1] - 800.0),(AproxRandomSpaceToWalkTo[1] + 800.0));

	b_IgnoreAllCollisionNPC[npc.index]=false;

	Handle ToGroundTrace = TR_TraceRayFilterEx(AproxRandomSpaceToWalkTo, view_as<float>( { 90.0, 0.0, 0.0 } ), GetSolidMask(npc.index), RayType_Infinite, BulletAndMeleeTrace, npc.index);
		
	b_IgnoreAllCollisionNPC[npc.index]=true;
	TR_GetEndPosition(AproxRandomSpaceToWalkTo, ToGroundTrace);
	delete ToGroundTrace;

	CNavArea area = TheNavMesh.GetNearestNavArea(AproxRandomSpaceToWalkTo, true);
	if(area == NULL_AREA)
		return;

	int NavAttribs = area.GetAttributes();
	if(NavAttribs & NAV_MESH_AVOID)
	{
		return;
	}
			

	area.GetCenter(AproxRandomSpaceToWalkTo);

	AproxRandomSpaceToWalkTo[2] += 18.0;
		
	static float hullcheckmaxs_Player_Again[3];
	static float hullcheckmins_Player_Again[3];

	hullcheckmaxs_Player_Again = view_as<float>( { 45.0, 45.0, 82.0 } ); //Fat. very fett indeed
	hullcheckmins_Player_Again = view_as<float>( { -45.0, -45.0, 0.0 } );	

	if(IsSpaceOccupiedIgnorePlayers(AproxRandomSpaceToWalkTo, hullcheckmins_Player_Again, hullcheckmaxs_Player_Again, npc.index) || IsSpaceOccupiedOnlyPlayers(AproxRandomSpaceToWalkTo, hullcheckmins_Player_Again, hullcheckmaxs_Player_Again, npc.index))
	{
		return;
	}

	if(IsPointHazard(AproxRandomSpaceToWalkTo)) //Retry.
		return;

		
	AproxRandomSpaceToWalkTo[2] += 18.0;
	if(IsPointHazard(AproxRandomSpaceToWalkTo)) //Retry.
		return;

		
	AproxRandomSpaceToWalkTo[2] -= 18.0;
	AproxRandomSpaceToWalkTo[2] -= 18.0;
	AproxRandomSpaceToWalkTo[2] -= 18.0;

	if(IsPointHazard(AproxRandomSpaceToWalkTo)) //Retry.
		return;

		
	AproxRandomSpaceToWalkTo[2] += 18.0;
	AproxRandomSpaceToWalkTo[2] += 18.0;
	
	float npc_vec[3]; WorldSpaceCenter(npc.index, npc_vec);
	float flDistanceToBuild = GetVectorDistance(AproxRandomSpaceToWalkTo, npc_vec, true);
	
	float range = 500.0;
	if(flDistanceToBuild < (range * range))
	{
		return; //The building is too close, we want to retry! it is unfair otherwise.
	}
	//Retry.


	float Health = float(GetEntProp(npc.index, Prop_Data, "m_iHealth"))+1.0;
	int spawn_index = NPC_CreateByName("npc_ruina_magia_anchor", npc.index, AproxRandomSpaceToWalkTo, {0.0,0.0,0.0}, GetTeam(npc.index));
	if(spawn_index > MaxClients)
	{
		if(GetTeam(npc.index) != TFTeam_Red)
		{
			NpcAddedToZombiesLeftCurrently(spawn_index, true);
		}
		fl_ruina_battery[spawn_index]=255.0;	//force spawn them fully
		SetEntityRenderMode(spawn_index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(spawn_index, 255, 255, 255, 1);

		int i_health = RoundToFloor(Health);
		SetEntProp(spawn_index, Prop_Data, "m_iHealth", i_health);
		SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", i_health);

		npc.m_iState = EntIndexToEntRef(spawn_index);
	}
}

static int Storm_Weaver_Health(Storm_Weaver npc)
{
	int health = 1;
	if(b_stellar_weaver_true_solo)
	{	
		for(int targ; targ<i_MaxcountNpcTotal; targ++)
		{
			int baseboss_index = EntRefToEntIndex(i_ObjectsNpcsTotal[targ]);
			if (IsValidEntity(baseboss_index) && !b_NpcHasDied[baseboss_index])
			{
				if(!b_ignore_npc[baseboss_index])
				{
					if(GetTeam(npc.index) == GetTeam(baseboss_index))
					{
						if(IsEntityAlive(baseboss_index))
						{
							health+=GetEntProp(baseboss_index, Prop_Data, "m_iHealth");
						}
					}
				}
			}
		}
		if(health>10)
		health-=1;
	}
	else
	{
		health = Storm_Weaver_Return_Health(npc);
	}
	
	return health;
}

void Storm_Weaver_Share_With_Anchor_Damage(int iNPC, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{
	CClotBody npc = view_as<CClotBody>(iNPC);

	//CPrintToChatAll("three");

	if(i_HexCustomDamageTypes[npc.index] & ZR_DAMAGE_NPC_REFLECT)	//do not.
		return;

	if(damagetype & DMG_CLUB)	//if a person is brave enough to melee this thing, reward them handsomely
	{
		damage *=2.5;
	}
	else	//otherwise...
	{
		damage *= 0.75;
	}

	//CPrintToChatAll("four");
	
	if(attacker>MAXTF2PLAYERS)
	{
		int Anchor_Id = i_GetMagiaAnchor(npc);
		if(IsEntityAlive(Anchor_Id) && !b_NpcIsInvulnerable[Anchor_Id])
		{
			SDKHooks_TakeDamage(Anchor_Id, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, false, (ZR_DAMAGE_NOAPPLYBUFFS_OR_DEBUFFS|ZR_DAMAGE_NPC_REFLECT));
		}

		return;
	}

	if(i_storm_weaver_damage_instance[attacker]>=RUINA_DAMAGE_INSTANCES_PER_FRAME)
		return;

	i_storm_weaver_damage_instance[attacker]++;

	int Anchor_Id = i_GetMagiaAnchor(npc);
	if(IsEntityAlive(Anchor_Id) && !b_NpcIsInvulnerable[Anchor_Id])
	{
		SDKHooks_TakeDamage(Anchor_Id, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, false, (ZR_DAMAGE_NOAPPLYBUFFS_OR_DEBUFFS|ZR_DAMAGE_NPC_REFLECT));
		RequestFrame(Nulify_Instance, attacker);
	}

	//CPrintToChatAll("five");

	damage = 0.0;
}

static void Nulify_Instance(int client)
{
	i_storm_weaver_damage_instance[client]=0;
}

static void Storm_Weaver_Damage_Touch(int entity, int other)
{
	if(IsValidEnemy(entity, other, true, true)) //Must detect camo.
	{
		float GameTime = GetGameTime();
		if(fl_recently_teleported[entity]<GameTime)
		{
			if(fl_touch_timeout[other] < GameTime)
			{
				fl_touch_timeout[other] = GameTime+0.1;
				SDKHooks_TakeDamage(other, entity, entity, 30.0, DMG_CRUSH, -1);
			}
		}
	}
}

void Storm_Weaver_Delete_Collision(int iNPC)
{
	CClotBody npc = view_as<CClotBody>(iNPC);

	b_storm_weaver_noclip[npc.index]=true;
			
	SetEntProp(npc.index, Prop_Send, "m_usSolidFlags", 12);
	SetEntProp(npc.index, Prop_Data, "m_nSolidType", 6);
	SetEntityCollisionGroup(npc.index, 24);

}
void Storm_Weaver_Restore_Collisions(int iNPC)
{
	CClotBody npc = view_as<CClotBody>(iNPC);

	b_storm_weaver_noclip[npc.index]=false;

	SetEntProp(npc.index, Prop_Send, "m_usSolidFlags", 6);
	SetEntProp(npc.index, Prop_Data, "m_nSolidType", 2); 
	SetEntityCollisionGroup(npc.index, 6);
}
//TODO 
//Rewrite
static void ClotThink(int iNPC)
{
	Storm_Weaver npc = view_as<Storm_Weaver>(iNPC);
	
	f_StuckOutOfBoundsCheck[npc.index] = GetGameTime() + 10.0;
	float GameTime = GetGameTime(npc.index);

	if(fl_recently_teleported[npc.index] < GameTime)
		ResolvePlayerCollisions_Npc(iNPC, /*damage crush*/ 10.0);

	if(!IsValidEntity(npc.m_iState) && fl_special_invuln_timer[npc.index] < GameTime)
	{
		npc.m_bDissapearOnDeath = true;	
		//CPrintToChatAll("death cause no hp.");
		RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
		func_NPCThink[npc.index] = INVALID_FUNCTION;
		return;
	}

	if(npc.m_flNextDelayTime > GameTime)
	{
		return;
	}

	if(!IsValidEntity(RaidBossActive))
	{
		RaidBossActive=EntIndexToEntRef(npc.index);
	}


	npc.m_flNextDelayTime = GameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
			
	if(npc.m_blPlayHurtAnimation)
	{
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > GameTime)
	{
		return;
	}
	
	npc.m_flNextThinkTime = GameTime + 0.1;
	
	if(npc.m_flGetClosestTargetTime < GameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index, true);
		npc.m_flGetClosestTargetTime = GameTime + GetRandomRetargetTime();

		if(!IsValidEnemy(npc.index, npc.m_iTarget))	//a failsafe targeting system thats a LOT more forgiving.
		{
			npc.m_iTarget = Storm_Weaver_Get_Target(npc);
		}
	}
	if(!IsValidEntity(npc.m_iState))
	{
		int tower = i_GetMagiaAnchor(npc);
		if(IsValidEntity(tower))
			npc.m_iState = EntIndexToEntRef(tower);
	}

	if(b_storm_weaver_solo && !b_stellar_weaver_true_solo)
	{
		Storm_Weaver_Pulse_Solo_Mode(npc);
	}
	else
	{
		int Health = Storm_Weaver_Health(npc);
		SetEntProp(npc.index, Prop_Data, "m_iHealth", Health);
		SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", Health);		
	}
	int PrimaryThreatIndex = npc.m_iTarget;

	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		Storm_Weaver_Heading_Control(npc, PrimaryThreatIndex, GameTime);
		
		int Enemy_I_See;
				
		Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
		//Target close enough to hit
		if(IsValidEnemy(npc.index, Enemy_I_See)) //Check if i can even see.
		{
			float flDistanceToTarget, vecTarget[3];
			WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
			if(GameTime > npc.m_flNextRangedAttack)
			{
				npc.PlayMeleeHitSound();
				float projectile_speed = 1250.0;
				//lets pretend we have a projectile.
				if(flDistanceToTarget < 1250.0*1250.0)
					PredictSubjectPositionForProjectiles(npc, PrimaryThreatIndex, projectile_speed, 40.0, vecTarget);

				if(!Can_I_See_Enemy_Only(npc.index, PrimaryThreatIndex)) //cant see enemy in the predicted position, we will instead just attack normally
				{
					WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
				}
				float DamageDone = 50.0;
				npc.FireParticleRocket(vecTarget, DamageDone, projectile_speed, 0.0, "spell_fireball_small_blue", false, true, false,_,_,_,10.0);
				npc.m_flNextRangedAttack = GameTime + 1.1;
			}
		}
	}
	else	//random-ish wandering
	{
		if(!b_storm_weaver_solo)
		{

			int Anchor_Id = EntRefToEntIndex(i_traveling_to_anchor[npc.index]);
			if(IsValidEntity(Anchor_Id))
			{
				Storm_Weaver_Heading_Control(npc, Anchor_Id, GameTime);
			}
		}
		else
		{
			
		}
	}


}
static int Storm_Weaver_Get_Target(Storm_Weaver npc)
{
	float npc_vec[3]; GetAbsOrigin(npc.index, npc_vec);
	float last_dist = 3333333.0;
	int closest_yet = -1;
	for(int entity=0 ; entity < MAXENTITIES ; entity++)
	{
		if(IsValidEntity(entity))
		{
			if(IsValidEnemy(npc.index, entity))
			{
				float vecTarget[3]; WorldSpaceCenter(entity, vecTarget);
		
				float flDistanceToTarget = GetVectorDistance(vecTarget, npc_vec, true);

				if(flDistanceToTarget < last_dist)
				{
					last_dist=flDistanceToTarget;
					closest_yet=entity;
				}
			}
		}
	}
	return closest_yet;
}
static void Storm_Weaver_Heading_Control(Storm_Weaver npc, int Target, float GameTime)
{
	float Npc_Vec[3]; GetAbsOrigin(npc.index, Npc_Vec);

	if(IsValidEnemy(npc.index, Target))
	{
		int New_Target = GetClosestTarget(npc.index, true, _, _, _, _, _, true);	//ignore buildings, only attack what it can see!
		if(!IsValidEntity(New_Target))
		{
			New_Target = Target;
		}
		else
		{
			//fl_cantseetimeout[npc.index] = GameTime + RUINA_CANTSEE_TIMEOUT;
		}

		if(npc.IsOnGround())
		{
			Npc_Vec[2] += 50.0;
			TeleportEntity(npc.index, Npc_Vec, NULL_VECTOR, NULL_VECTOR); 
		}
		b_NoGravity[npc.index] = true;	//Found ya!

		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;

		float target_vec[3], flDistanceToTarget; GetAbsOrigin(New_Target, target_vec);

		flDistanceToTarget = GetVectorDistance(target_vec, Npc_Vec, true);

		if(flDistanceToTarget>(150.0*150.0))
			target_vec[2]+=135.0;
		else
			target_vec[2]+=75.0;


		Storm_Weaver_Fly(npc, target_vec, GameTime);

	}
	else
	{
		float target_vec[3]; GetAbsOrigin(Target, target_vec);

		target_vec[2]+=75.0;

		Storm_Weaver_Fly(npc, target_vec, GameTime);
	}
}
stock void Storm_Weaver_Fly(Storm_Weaver npc, float target_vec[3], float GameTime)
{
	float npc_vec[3]; GetAbsOrigin(npc.index, npc_vec);

	float newVel[3];
	
	GetEntPropVector(npc.index, Prop_Data, "m_vecVelocity", newVel);

	float vecAngles[3];
	MakeVectorFromPoints(npc_vec, target_vec, vecAngles);
	GetVectorAngles(vecAngles, vecAngles);

	vecAngles[0]-=90.0;

	TeleportEntity(npc.index, NULL_VECTOR, vecAngles, NULL_VECTOR);

	float max_speed = RUINA_STORM_WEAVER_FLIGHT_SPEED;

	float Acceleration = 75.0;

	//if(speed)
	//	Acceleration = RUINA_STORM_WEAVER_FLIGHT_SPEED*0.75;

	for(int vec=0 ; vec <=2 ; vec++)
	{
		if(npc_vec[vec]<target_vec[vec])
		{
			newVel[vec] += Acceleration;

			//newVel[vec] += 75.0;
		}
		else
		{
			newVel[vec] -= Acceleration;

			//newVel[vec] -= 75.0;
		}
		
		if(newVel[vec]>max_speed || newVel[vec] < max_speed*-1.0)	//max speed
		{
			if(newVel[vec]<0)
			{
				newVel[vec] = max_speed*-1;
			}
			else
			{
				newVel[vec] = max_speed;
			}
		}
	}

	/*if(!Storm_Weaver_Check_Heading_Walls(npc, 2, -1))	// don't let it touch the ground at all costs
	{
		newVel[2] = 0.0;
		newVel[2] = 25.0;
	}*/

	npc.SetVelocity(newVel);

}
/*
static bool Storm_Weaver_Check_Heading_Walls(Storm_Weaver npc)
{

	float npc_vec[3]; GetAbsOrigin(npc.index, npc_vec);

	float maxes[3] = { -30.0, -30.0, -30.0 };
	float mins[3] = { 30.0, 30.0, 30.0 };

	Handle hTrace = TR_TraceHullFilterEx(npc_vec, npc_vec, mins, maxes, MASK_PLAYERSOLID, TraceRayDontHitPlayersOrEntityCombat, npc.index);

	if(TR_DidHit(hTrace))
	{
		delete hTrace;
		return false;
	}
	else
	{
		delete hTrace;
		return true;
	}

}
*/
static Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Storm_Weaver npc = view_as<Storm_Weaver>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;

	Ruina_NPC_OnTakeDamage_Override(npc.index, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);

	//CPrintToChatAll("one");
		
	if(!b_storm_weaver_solo && !b_stellar_weaver_true_solo)
	{
	//	CPrintToChatAll("two");
		Storm_Weaver_Share_With_Anchor_Damage(npc.index, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition);
		
		Ruina_Add_Battery(npc.index, damage);	//turn damage taken into energy
		damage=0.0;	//storm weaver doesn't really take any damage, his "health bar" is just the combined health of all the towers


		//int Health = Storm_Weaver_Health();
		//SetEntProp(npc.index, Prop_Data, "m_iHealth", Health);
	}
	else
	{
		Stellar_Weaver_Share_Damage_With_All(npc.index, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition);

		Ruina_Add_Battery(npc.index, damage);	//turn damage taken into energy

		damage = 0.0;

	}
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}
void Stellar_Weaver_Share_Damage_With_All(int iNPC, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{
	CClotBody npc = view_as<CClotBody>(iNPC);

	if(i_HexCustomDamageTypes[npc.index] & ZR_DAMAGE_NPC_REFLECT)	//do not.
		return;
	
	if(attacker<MAXTF2PLAYERS)
	{
		//CPrintToChatAll("Dmg Instance Amt: %i", i_storm_weaver_damage_instance[attacker]);
		if(i_storm_weaver_damage_instance[attacker]>=RUINA_DAMAGE_INSTANCES_PER_FRAME)
		return;
	
		i_storm_weaver_damage_instance[attacker]++;
	}
	int valid_id[NPC_HARD_LIMIT+1];
	Zero(valid_id);
	int total=0;

	for(int targ; targ<i_MaxcountNpcTotal; targ++)
	{
		int baseboss_index = EntRefToEntIndex(i_ObjectsNpcsTotal[targ]);
		if (IsValidEntity(baseboss_index) && !b_NpcHasDied[baseboss_index])
		{
			if(!b_ignore_npc[baseboss_index])
			{
				if(IsEntityAlive(baseboss_index) && GetTeam(baseboss_index) != TFTeam_Red)
				{
					if(IsEntityAlive(baseboss_index) && !b_NpcIsInvulnerable[baseboss_index])
					{
						if(targ <= NPC_HARD_LIMIT)
						{
							valid_id[targ]=baseboss_index;
							total++;
						}	
					}
				}
			}
		}
	}
	if(total<=0)
	{
		//CPrintToChatAll("somehow 0 dmg on share all weaver!");
		if(attacker<MAXTF2PLAYERS)
			RequestFrame(Nulify_Instance, attacker);
		return;
	}
	for(int i=0 ; i < NPC_HARD_LIMIT ; i++)
	{
		int other_npc = valid_id[i];
		if(IsValidEntity(other_npc))
		{
			SDKHooks_TakeDamage(other_npc, attacker, inflictor, damage/total, damagetype, weapon, damageForce, damagePosition, false, (ZR_DAMAGE_NOAPPLYBUFFS_OR_DEBUFFS|ZR_DAMAGE_NPC_REFLECT));
		}	
	}
	if(attacker<MAXTF2PLAYERS)
		RequestFrame(Nulify_Instance, attacker);
}

static void NPC_Death(int entity)
{
	Storm_Weaver npc = view_as<Storm_Weaver>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}

	if(EntRefToEntIndex(RaidBossActive)==entity)
	{
		RaidBossActive = INVALID_ENT_REFERENCE;
	}

	b_ignore_npc[npc.index]=false;

	for(int i=0 ; i < RUINA_STORM_WEAVER_LENGHT ; i++)
	{
		int tails = EntRefToEntIndex(i_segment_id[npc.index][i]);
		if(IsValidEntity(tails))
		{
			Storm_Weaver_Mid tail = view_as<Storm_Weaver_Mid>(tails);
			tail.m_iState = -1;
		}
	}

	npc.m_iState = -1;
	Ruina_NPCDeath_Override(entity);
}