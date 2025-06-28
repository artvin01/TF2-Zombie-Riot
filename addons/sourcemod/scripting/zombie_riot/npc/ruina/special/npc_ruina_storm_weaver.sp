#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"mvm/mvm_bomb_explode.wav",
};

static char g_HurtSounds[][] = {
	")physics/metal/metal_box_impact_bullet1.wav",
	")physics/metal/metal_box_impact_bullet2.wav",
	")physics/metal/metal_box_impact_bullet3.wav",
};

static const char g_AttackSounds[][] = {
	"weapons/dragons_fury_shoot.wav",
};
static const char g_AdvAttackSounds[][] = {
	"weapons/dragons_fury_pressure_build.wav",
};

//#define STELLAR_WEAVER_THEME "#zombiesurvival/ruina/storm_weaver_test.mp3"

#define RUINA_STORM_WEAVER_MODEL "models/props_moonbase/moon_gravel_crystal_blue.mdl" //"models/props_borealis/bluebarrel001.mdl"
#define RUINA_STORM_WEAVER_HEAD_MODEL "models/props_moonbase/moon_gravel_crystal_blue.mdl" //"models/props_borealis/bluebarrel001.mdl"
#define RUINA_STORM_WEAVER_MODEL_SIZE "2.0"	//2.0
#define RUINA_STELLAR_WEAVER_LENGTH 12	//12

#define RUINA_STORM_WEAVER_FLIGHT_SPEED 315.0

#define RUINA_DAMAGE_INSTANCES_PER_FRAME 1	//a player can only dmg the worm x times a frame, to make piercing weapons not delete him stupidly easily
#define RUINA_CANTSEE_TIMEOUT 0.5

static int SaveSolidFlags[MAXENTITIES];
static int SaveSolidType[MAXENTITIES];


bool b_storm_weaver_solo;
bool b_stellar_weaver_true_solo;
bool b_stellar_weaver_allow_attack[MAXENTITIES];
float fl_stellar_weaver_special_attack_offset;
int i_storm_weaver_damage_instance[MAXENTITIES];
static float fl_trace_timeout[MAXENTITIES];
static float fl_recently_teleported[MAXENTITIES];
static float fl_teleport_time[MAXENTITIES];
//static float fl_teleporting_time[MAXENTITIES];
static int i_segment_id[MAXENTITIES][RUINA_STELLAR_WEAVER_LENGTH+1];
static float fl_special_invuln_timer[MAXENTITIES];
static bool b_ignore_npc[MAXENTITIES];

enum struct Ruina_Flight_Pather
{
	int index;
	float GoLoc[3];
	float Acceleration;
	float Speed;

	int Create(float Origin[3])
	{
		int dot = Ruina_Create_Entity(Origin, 0.0, false);

		if(!IsValidEntity(dot))
			return -1;
		
		this.index = EntIndexToEntRef(dot);

		/*
			Gravity... Gravity is a harness.
			My entire career has been devoted to this idea... to, this moment. Decades!
			If the unifying theories are correct, we will soon be able to harness the power of a black hole. Nothing will ever be the same!

			Freedom... Imprisonment... It's all an illusion.
			Gravity is a harness. I have harnessed the harness.
		*/
		SetEntityGravity(dot, 0.001);

		MakeObjectIntangeable(dot);

		b_NoGravity[dot] = true;

		return dot;
	}
	void Fly()
	{
		int dot = EntRefToEntIndex(this.index);

		if(!IsValidEntity(dot))
		{
			this.Create(this.GoLoc);
			return;
		}

		float npc_vec[3]; GetAbsOrigin(dot, npc_vec);

		float newVel[3];
		
		GetEntPropVector(dot, Prop_Data, "m_vecVelocity", newVel);

		float max_speed = this.Speed;

		float Acceleration = this.Acceleration;

		float target_vec[3]; target_vec = this.GoLoc;

		for(int vec=0 ; vec <=2 ; vec++)
		{
			if(npc_vec[vec]<target_vec[vec])
			{
				newVel[vec] += Acceleration;
			}
			else
			{
				newVel[vec] -= Acceleration;
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
		TeleportEntity(dot, NULL_VECTOR, NULL_VECTOR, newVel);
	}	
}

Ruina_Flight_Pather Flight_Computer[MAXENTITIES];

void Ruina_Storm_Weaver_MapStart()
{
	//beam_model = PrecacheModel(BLITZLIGHT_SPRITE);

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Stellar Weaver");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_ruina_stellar_weaver");
	data.Category = Type_Ruina;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	strcopy(data.Icon, sizeof(data.Icon), ""); 						//leaderboard_class_(insert the name)
	data.IconCustom = false;												//download needed?
	data.Flags = 0;						//example: MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;, forces these flags.	
	NPC_Add(data);
}
static void ClotPrecache()
{
	Zero(b_stellar_weaver_allow_attack);
	Zero(b_ignore_npc);
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_AttackSounds);
	PrecacheSoundArray(g_AdvAttackSounds);

	//PrecacheSoundCustom(STELLAR_WEAVER_THEME);

	Zero2(i_segment_id);

	PrecacheModel(RUINA_STORM_WEAVER_HEAD_MODEL);
	Zero(i_storm_weaver_damage_instance);
}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return Storm_Weaver(vecPos, vecAng, team, data);
}

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
	
	public void PlayBasicAttackSound() {
		EmitSoundToAll(g_AttackSounds[GetRandomInt(0, sizeof(g_AttackSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
	}

	public void PlayerAdvAttackSound() {
		EmitSoundToAll(g_AdvAttackSounds[GetRandomInt(0, sizeof(g_AdvAttackSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
	}
	
	public Storm_Weaver(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Storm_Weaver npc = view_as<Storm_Weaver>(CClotBody(vecPos, vecAng, RUINA_STORM_WEAVER_HEAD_MODEL, RUINA_STORM_WEAVER_MODEL_SIZE, "1250", ally));
		
		i_NpcWeight[npc.index] = 999;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");

		//if(ally != TFTeam_Red)
		//{
		//	//b_thisNpcIsABoss[npc.index] = true;
		//}

		SaveSolidFlags[npc.index]=GetEntProp(npc.index, Prop_Send, "m_usSolidFlags");
		SaveSolidType[npc.index]=GetEntProp(npc.index, Prop_Send, "m_nSolidType");

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

		float Origin[3]; WorldSpaceCenter(npc.index, Origin);
		Flight_Computer[npc.index].Create(Origin);
		Flight_Computer[npc.index].Speed = RUINA_STORM_WEAVER_FLIGHT_SPEED*fl_Extra_Speed[npc.index];
		Flight_Computer[npc.index].Acceleration = 75.0;

		//Flies through everything, but can still be hit/calls hits?
		b_IgnoreAllCollisionNPC[npc.index] = true;
		f_NoUnstuckVariousReasons[npc.index] = FAR_FUTURE;

		if(!IsValidEntity(npc.m_iState))
			npc.m_iState = INVALID_ENT_REFERENCE;

		if(!IsValidEntity(RaidBossActive))
		{
			RaidBossActive = EntIndexToEntRef(npc.index);
			RaidAllowsBuildings = true;

			RaidModeTime = FAR_FUTURE;

			/*MusicEnum music;
			strcopy(music.Path, sizeof(music.Path), STELLAR_WEAVER_THEME);
			music.Time = 350;
			music.Volume = 1.0;
			music.Custom = true;
			strcopy(music.Name, sizeof(music.Name), "''Servants of The Scourge'' - Theme of The Sentinels of The Devourer");
			strcopy(music.Artist, sizeof(music.Artist), "DM DOKURO");
			Music_SetRaidMusic(music);*/
		}

		fl_teleport_time[npc.index]=0.0;
		fl_recently_teleported[npc.index]=0.0;

		npc.StopPathing();
		

		bool solo = StrContains(data, "solo") != -1;

		bool true_solo = StrContains(data, "solo_true") != -1;

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

		//now the fun part, making him ignore all collisions...

		b_NoGravity[npc.index] = true;	//Found ya!

		float npc_vec[3]; GetAbsOrigin(npc.index, npc_vec);
		npc_vec[2] += 50.0;

		TeleportEntity(npc.index, npc_vec, NULL_VECTOR, NULL_VECTOR);

		ParticleEffectAt(npc_vec, "eyeboss_death_vortex", 5.0);

		b_ignore_npc[npc.index]=true;
		int follow_id = npc.index;
		for(int i=0 ; i< RUINA_STELLAR_WEAVER_LENGTH ; i++)
		{
			int buffer = Storm_Weaver_Create_Tail(npc, follow_id, i);
			follow_id = buffer;
		}

		b_NoKnockbackFromSources[npc.index] = true;
		b_ThisNpcIsImmuneToNuke[npc.index] = true;

		fl_ruina_battery[npc.index] = 0.0;

		npc.m_bDissapearOnDeath = true;
		b_stellar_weaver_allow_attack[npc.index] = false;

		npc.m_flMeleeArmor = 2.0;
		
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
		b_stellar_weaver_allow_attack[spawn_index] = false;
		//Flies through everything, but can still be hit/calls hits?
		b_IgnoreAllCollisionNPC[spawn_index] = true;
		f_NoUnstuckVariousReasons[spawn_index] = FAR_FUTURE;
		AddNpcToAliveList(spawn_index, 1);

		SaveSolidFlags[spawn_index]=GetEntProp(spawn_index, Prop_Send, "m_usSolidFlags");
		SaveSolidType[spawn_index]=GetEntProp(spawn_index, Prop_Send, "m_nSolidType");

		fl_Extra_Damage[spawn_index] = fl_Extra_Damage[npc.index];
		fl_Extra_MeleeArmor[spawn_index] = fl_Extra_MeleeArmor[npc.index];
		fl_Extra_RangedArmor[spawn_index] = fl_Extra_RangedArmor[npc.index];

		//b_ForceCollisionWithProjectile[spawn_index]=true;
		if(GetTeam(npc.index) != TFTeam_Red)
			NpcAddedToZombiesLeftCurrently(spawn_index, true);
		CClotBody tail = view_as<CClotBody>(spawn_index);
		tail.m_flNextRangedAttack = GetGameTime(tail.index)+1.0+(Section/10.0);
		SetEntProp(spawn_index, Prop_Data, "m_iHealth", Health);
		SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", Health);
		tail.m_flMeleeArmor = 2.0;
	}
	return spawn_index;
}
void Storm_Weaver_Middle_Movement(Storm_Weaver_Mid npc, float loc[3])
{
	float vecView[3], vecFwd[3], Entity_Loc[3], vecVel[3];
	
	GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", Entity_Loc);
		
	//if(npc.IsOnGround())
	//{
	//	Entity_Loc[2] += 50.0;
	//	PluginBot_Jump(npc.index, Entity_Loc);
	//}

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
}
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
	
	float npc_vec[3]; WorldSpaceCenter(npc.index, npc_vec);
	float flDistanceToBuild = GetVectorDistance(AproxRandomSpaceToWalkTo, npc_vec, true);
	
	float range = 500.0;
	if(flDistanceToBuild < (range * range))
	{
		return; //The building is too close, we want to retry! it is unfair otherwise.
	}
	//Retry.


	float Health = float(GetEntProp(npc.index, Prop_Data, "m_iHealth"))+1.0;
	int spawn_index = NPC_CreateByName("npc_ruina_magia_anchor", npc.index, AproxRandomSpaceToWalkTo, {0.0,0.0,0.0}, GetTeam(npc.index), "full");
	if(spawn_index > MaxClients)
	{
		NpcStats_CopyStats(npc.index, spawn_index);
		if(GetTeam(npc.index) != TFTeam_Red)
		{
			NpcAddedToZombiesLeftCurrently(spawn_index, true);
		}

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
			int baseboss_index = EntRefToEntIndexFast(i_ObjectsNpcsTotal[targ]);
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

	//CPrintToChatAll("four");

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

static void ClotThink(int iNPC)
{
	Storm_Weaver npc = view_as<Storm_Weaver>(iNPC);
	
	f_StuckOutOfBoundsCheck[npc.index] = GetGameTime() + 10.0;
	float GameTime = GetGameTime(npc.index);

	//should result in a total of 300 dmg a second.
	//*should*
	ResolvePlayerCollisions_Npc(iNPC, /*damage crush*/ (4.545/TickrateModify) * ((Waves_GetRoundScale()+1)/40.0), true);

	if(!IsValidAlly(npc.index, EntRefToEntIndex(npc.m_iState)) && fl_special_invuln_timer[npc.index] < GameTime)
	{
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

	float Gain = 10.0;
	if(!b_stellar_weaver_allow_attack[npc.index])
		Ruina_Add_Battery(npc.index, Gain);

	
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

	float Battery_Cost = 3500.0;
	float battery_Ratio = (fl_ruina_battery[npc.index]/Battery_Cost);

	if(fl_ruina_battery[npc.index] > Battery_Cost)
	{
		Initiate_Attack(npc);
		fl_ruina_battery[npc.index] = 0.0;
	}
			

	if(npc.index==EntRefToEntIndex(RaidBossActive))
	{
		RaidModeScaling = battery_Ratio;
	}
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		Storm_Weaver_Heading_Control(npc, PrimaryThreatIndex);
		
		int Enemy_I_See;
				
		Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
		//Target close enough to hit
		if(IsValidEnemy(npc.index, Enemy_I_See)) //Check if i can even see.
		{
			float flDistanceToTarget, vecTarget[3];
			WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);

			if(b_stellar_weaver_allow_attack[npc.index] && fl_stellar_weaver_special_attack_offset < GameTime)
			{
				float Ratio = (Waves_GetRoundScale()+1)/40.0;
				fl_stellar_weaver_special_attack_offset = GameTime + 0.1;
				Stellar_Weaver_Attack(npc.index, vecTarget, 50.0*Ratio, 500.0, 15.0, 500.0*Ratio, 150.0, 10.0);
				b_stellar_weaver_allow_attack[npc.index] = false;
			}
			if(GameTime > npc.m_flNextRangedAttack)
			{
				npc.PlayBasicAttackSound();
				float projectile_speed = 1250.0;
				//lets pretend we have a projectile.
				if(flDistanceToTarget < 1250.0*1250.0)
					PredictSubjectPositionForProjectiles(npc, PrimaryThreatIndex, projectile_speed, 40.0, vecTarget);

				if(!Can_I_See_Enemy_Only(npc.index, PrimaryThreatIndex)) //cant see enemy in the predicted position, we will instead just attack normally
				{
					WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
				}
				float Ratio = (Waves_GetRoundScale()+1)/40.0;
				float DamageDone = 100.0*Ratio;
				npc.FireParticleRocket(vecTarget, DamageDone, projectile_speed, 0.0, "spell_fireball_small_blue", false, true, false,_,_,_,10.0);
				npc.m_flNextRangedAttack = GameTime + 1.1;
			}
		}
	}
	else	//random-ish wandering
	{
		npc.m_flGetClosestTargetTime = 0.0;
	}
}
static void Initiate_Attack(Storm_Weaver npc)
{
	b_stellar_weaver_allow_attack[npc.index] = true;

	fl_stellar_weaver_special_attack_offset = 0.0;

	for(int i=0 ; i < RUINA_STELLAR_WEAVER_LENGTH ; i++)
	{
		int tails = EntRefToEntIndex(i_segment_id[npc.index][i]);
		if(IsValidEntity(tails))
		{
			b_stellar_weaver_allow_attack[tails] = true;
		}
	}
}	
static int i_laser_entity[MAXENTITIES];
void Stellar_Weaver_Attack(int iNPC, float VecTarget[3], float dmg, float speed, float radius, float direct_damage, float direct_radius, float time, bool homing = false)
{
	float SelfVec[3];
	Ruina_Projectiles Projectile;
	WorldSpaceCenter(iNPC, SelfVec);
	Projectile.iNPC = iNPC;
	Projectile.Start_Loc = SelfVec;
	float Ang[3];
	MakeVectorFromPoints(SelfVec, VecTarget, Ang);
	GetVectorAngles(Ang, Ang);
	Projectile.Angles = Ang;
	Projectile.speed = speed;
	Projectile.radius = direct_radius;
	Projectile.damage = direct_damage;
	Projectile.bonus_dmg = direct_damage*2.5;
	Projectile.Time = time;
	Projectile.visible = false;
	int Proj = Projectile.Launch_Projectile(Func_On_Proj_Touch);		

	if(IsValidEntity(Proj))
	{
		float 	f_start = 0.9*radius,
				f_end = 0.75*radius,
				amp = 0.25;


		
		int color[4];
		Ruina_Color(color);
		int beam = ConnectWithBeamClient(iNPC, Proj, color[0], color[1], color[2], f_start*0.5, f_end*0.5, amp, LASERBEAM);
		i_laser_entity[Proj] = EntIndexToEntRef(beam);
		DataPack pack;
		CreateDataTimer(0.1, Laser_Projectile_Timer, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		pack.WriteCell(EntIndexToEntRef(iNPC));
		pack.WriteCell(EntIndexToEntRef(beam));
		pack.WriteCell(EntIndexToEntRef(Proj));
		pack.WriteCellArray(color, sizeof(color));
		pack.WriteFloat(radius);
		pack.WriteFloat(dmg);

		if(homing)
		{
			Initiate_HomingProjectile(Proj,
			iNPC,
			80.0,			// float lockonAngleMax,
			4.5,			// float homingaSec,
			true,			// bool LockOnlyOnce,
			false,			// bool changeAngles,
			Ang
			);
		}
	}
}

static void Func_On_Proj_Touch(int entity, int other)
{
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if(!IsValidEntity(owner))	//owner is invalid, evacuate.
	{
		Ruina_Remove_Projectile(entity);
		return;
	}

	int beam = EntRefToEntIndex(i_laser_entity[entity]);
	if(IsValidEntity(beam))
		RemoveEntity(beam);

	i_laser_entity[entity] = INVALID_ENT_REFERENCE;
	
	float ProjectileLoc[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);

	Explode_Logic_Custom(fl_ruina_Projectile_dmg[entity] , owner , owner , -1 , ProjectileLoc , fl_ruina_Projectile_radius[entity] , _ , _ , true, _,_, fl_ruina_Projectile_bonus_dmg[entity]);

	Ruina_Remove_Projectile(entity);

}

static Action Laser_Projectile_Timer(Handle timer, DataPack data)
{
	data.Reset();
	int iNPC = EntRefToEntIndex(data.ReadCell());
	int Laser_Entity = EntRefToEntIndex(data.ReadCell());
	int Projectile = EntRefToEntIndex(data.ReadCell());
	int color[4];
	data.ReadCellArray(color, sizeof(color));
	float Radius	= data.ReadFloat();
	float dmg 		= data.ReadFloat();

	if(!IsValidEntity(iNPC) || !IsValidEntity(Laser_Entity) || !IsValidEntity(Projectile))
	{
		if(IsValidEntity(Laser_Entity))
			RemoveEntity(Laser_Entity);

		if(IsValidEntity(Projectile))
			RemoveEntity(Projectile);
		
		return Plugin_Stop;
	}

	Ruina_Laser_Logic Laser;

	float SelfVec[3];
	WorldSpaceCenter(iNPC, SelfVec);
	float Proj_Vec[3];
	GetEntPropVector(Projectile, Prop_Data, "m_vecAbsOrigin", Proj_Vec);
	Laser.client = iNPC;
	Laser.Start_Point = SelfVec;
	Laser.End_Point = Proj_Vec;

	Laser.Radius = Radius;
	Laser.Damage = dmg;
	Laser.Bonus_Damage = dmg*6.0;
	Laser.damagetype = DMG_PLASMA;

	Laser.Deal_Damage();


	return Plugin_Continue;
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
static void Storm_Weaver_Heading_Control(Storm_Weaver npc, int Target)
{
	float Npc_Vec[3]; GetAbsOrigin(npc.index, Npc_Vec);
	
	//enemy target
	int New_Target = GetClosestTarget(npc.index, true, _, _, _, _, _, true);	//ignore buildings, only attack what it can see!
	if(!IsValidEntity(New_Target))
	{
		New_Target = Target;
	}

	//if(npc.IsOnGround())
	//{
	//	Npc_Vec[2] += 50.0;
	//	PluginBot_Jump(npc.index, Npc_Vec);
	//}
	b_NoGravity[npc.index] = true;	//Found ya!

	npc.StopPathing();
	

	float target_vec[3], flDistanceToTarget; GetAbsOrigin(New_Target, target_vec);

	flDistanceToTarget = GetVectorDistance(target_vec, Npc_Vec, true);

	if(flDistanceToTarget>(150.0*150.0))
		target_vec[2]+=135.0;
	else
		target_vec[2]+=75.0;


	Storm_Weaver_Fly(npc, target_vec);
}
static void Storm_Weaver_Fly(Storm_Weaver npc, float target_vec[3])
{

	Flight_Computer[npc.index].GoLoc = target_vec;
	Flight_Computer[npc.index].Fly();
	int dot = EntRefToEntIndex(Flight_Computer[npc.index].index);
	if(!IsValidEntity(dot))
		return;

	float HeadFollow[3];
	WorldSpaceCenter(dot,HeadFollow);

	float npc_vec[3]; GetAbsOrigin(npc.index, npc_vec);

	Storm_Weaver_Mid worm_head = view_as<Storm_Weaver_Mid>(npc.index);


	Storm_Weaver_Middle_Movement(worm_head, HeadFollow);
}
static Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Storm_Weaver npc = view_as<Storm_Weaver>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;

	Ruina_NPC_OnTakeDamage_Override(npc.index, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
	if(!b_storm_weaver_solo && !b_stellar_weaver_true_solo)
	{
		Storm_Weaver_Share_With_Anchor_Damage(npc.index, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition);
		
		Ruina_Add_Battery(npc.index, damage);	//turn damage taken into energy
		damage=0.0;	//storm weaver doesn't really take any damage, his "health bar" is just the combined health of all the towers

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
	
	if(attacker<MAXPLAYERS)
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
		int baseboss_index = EntRefToEntIndexFast(i_ObjectsNpcsTotal[targ]);
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
		if(attacker<MAXPLAYERS)
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
	if(attacker<MAXPLAYERS)
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

	float pos1[3];
	GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", pos1);
	DataPack pack_boom1 = new DataPack();
	pack_boom1.WriteFloat(pos1[0]);
	pack_boom1.WriteFloat(pos1[1]);
	pack_boom1.WriteFloat(pos1[2]);
	pack_boom1.WriteCell(1);
	RequestFrame(MakeExplosionFrameLater, pack_boom1);

	int dot = EntRefToEntIndex(Flight_Computer[npc.index].index);
	if(IsValidEntity(dot))
		RemoveEntity(dot);
	
	Flight_Computer[npc.index].index = INVALID_ENT_REFERENCE;

	b_ignore_npc[npc.index]=false;

	for(int i=0 ; i < RUINA_STELLAR_WEAVER_LENGTH ; i++)
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