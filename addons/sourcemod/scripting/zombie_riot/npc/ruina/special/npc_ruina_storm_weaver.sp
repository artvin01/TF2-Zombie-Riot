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

static const char g_IdleMusic[][] = {
	"#zombiesurvival/altwaves_and_blitzkrieg/music/blitz_theme.mp3",	//temp raidmode stuff
};

#define RUINA_STORM_WEAVER_MODEL "models/props_borealis/bluebarrel001.mdl"
#define RUINA_STORM_WEAVER_HEAD_MODEL "models/props_borealis/bluebarrel001.mdl"
#define RUINA_STORM_WEAVER_MODEL_SIZE "1.0"	//1.0
#define RUINA_STORM_WEAVER_LENGHT 10	//10

#define RUINA_STORM_WEAVER_NOCLIP_SPEED 250.0
#define RUINA_STORM_WEAVER_FLIGHT_SPEED 315.0

#define RUINA_DAMAGE_INSTANCES_PER_FRAME 1	//a player can only dmg the worm x times a frame, to make piercing weapons not delete him stupidly easily
#define RUINA_CANTSEE_TIMEOUT 5.0

bool b_storm_weaver_solo;
int i_storm_weaver_health;
int i_storm_weaver_damage_instance[MAXTF2PLAYERS+1];
static float fl_recently_teleported[MAXENTITIES];
static float fl_distance_to_keep[MAXENTITIES];
static float fl_cantseetimeout[MAXENTITIES];
static float fl_teleport_time[MAXENTITIES];
static float fl_teleporting_time[MAXENTITIES];
static int i_segment_id[MAXENTITIES][RUINA_STORM_WEAVER_LENGHT+1];
static int i_traveling_to_anchor[MAXENTITIES];

//static int beam_model;


void Ruina_Storm_Weaver_MapStart()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_IdleMusic));   i++) { PrecacheSoundCustom(g_IdleMusic[i]);   }

	Zero2(i_segment_id);

	PrecacheModel(RUINA_STORM_WEAVER_HEAD_MODEL);
	Zero(i_storm_weaver_damage_instance);

	//beam_model = PrecacheModel(BLITZLIGHT_SPRITE);
}

methodmap Storm_Weaver < CClotBody
{
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayHurtSound()");
		#endif
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayDeathSound()");
		#endif
	}
	
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
	
	public Storm_Weaver(int client, float vecPos[3], float vecAng[3], bool ally, const char[] data)
	{
		Storm_Weaver npc = view_as<Storm_Weaver>(CClotBody(vecPos, vecAng, RUINA_STORM_WEAVER_HEAD_MODEL, RUINA_STORM_WEAVER_MODEL_SIZE, "1250", ally));
		
		i_NpcInternalId[npc.index] = RUINA_STORM_WEAVER;
		i_NpcWeight[npc.index] = 999;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");


		if(!ally)
		{
			b_thisNpcIsABoss[npc.index] = true;
		}

		b_DoNotUnStuck[npc.index] = true;
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		Ruina_Set_Heirarchy(npc.index, 2);

		Ruina_Set_No_Retreat(npc.index);

		Zero(i_storm_weaver_damage_instance);
		
		SDKHook(npc.index, SDKHook_Think, Storm_Weaver_ClotThink);
		
		npc.m_flGetClosestTargetTime = 0.0;

		RaidBossActive = EntIndexToEntRef(npc.index);	//temp raidmode stuff

		fl_cantseetimeout[npc.index]=GetGameTime()+RUINA_CANTSEE_TIMEOUT+2.5;
		fl_teleport_time[npc.index]=0.0;
		fl_recently_teleported[npc.index]=0.0;

		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;

		Music_SetRaidMusic(g_IdleMusic[GetRandomInt(0, sizeof(g_IdleMusic) - 1)], 228, true);

		bool solo = StrContains(data, "solo") != -1;

		if(i_magia_anchors_active<=0)
			solo=true;

		if(!solo)
		{
			b_storm_weaver_solo=false;
			int Health = Storm_Weaver_Health();
			i_storm_weaver_health = Health;
			SetEntProp(npc.index, Prop_Data, "m_iHealth", Health);
			SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", Health);
		}
		else
		{
			i_storm_weaver_health = GetEntProp(npc.index, Prop_Data, "m_iHealth");
			b_storm_weaver_solo=true;
		}


		RaidModeScaling = float(ZR_GetWaveCount()+1);	

		if(RaidModeScaling < 55)
		{
			RaidModeScaling *= 0.16; //abit low, inreacing
		}
		else
		{
			RaidModeScaling *= 0.33;
		}
		
		float amount_of_people = float(CountPlayersOnRed());

		if(amount_of_people > 12.0)
		{
			amount_of_people = 12.0;
		}

		amount_of_people *= 0.12;
		
		if(amount_of_people < 1.0)
			amount_of_people = 1.0;
			
		RaidModeScaling *= amount_of_people; //More then 9 and he raidboss gets some troubles, bufffffffff

		/*
		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				LookAtTarget(client_check, npc.index);
				SetGlobalTransTarget(client_check);
				ShowGameText(client_check, "voice_player", 1, "%t", "Blitzkrieg Spawn");
			}
		}*/


		i_traveling_to_anchor[npc.index]=-1;
		//now the fun part, making him ignore all collisions...

		b_NoGravity[npc.index] = true;	//Found ya!

		float npc_vec[3]; npc_vec = GetAbsOrigin(npc.index);
		npc_vec[2] += 50.0;

		TeleportEntity(npc.index, npc_vec, NULL_VECTOR, NULL_VECTOR);

		ParticleEffectAt(npc_vec, "eyeboss_death_vortex", 5.0);

		int follow_id = npc.index;
		for(int i=0 ; i< RUINA_STORM_WEAVER_LENGHT ; i++)
		{
			int buffer = Storm_Weaver_Create_Tail(npc, follow_id, i);
			follow_id = buffer;
		}

		b_NoKnockbackFromSources[npc.index] = true;
		b_ThisNpcIsImmuneToNuke[npc.index] = true;

		SDKHook(npc.index, SDKHook_Touch, Storm_Weaver_Damage_Touch);
		
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

	spawn_index = Npc_Create(RUINA_STORM_WEAVER_MID, -1, pos, ang, GetEntProp(npc.index, Prop_Send, "m_iTeamNum") == 2, buffer);
	i_segment_id[npc.index][Section] = EntIndexToEntRef(spawn_index);
	if(spawn_index > MaxClients)
	{
		Zombies_Currently_Still_Ongoing += 1;
		CClotBody tail = view_as<CClotBody>(spawn_index);
		tail.m_flNextRangedAttack = GetGameTime(tail.index)+1.0+(Section/10.0);
		SetEntProp(spawn_index, Prop_Data, "m_iHealth", Health);
		SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", Health);
		fl_distance_to_keep[npc.index] = 50.0;
	}
	return spawn_index;
}
static void Storm_Weaver_Nuke_Tail(Storm_Weaver npc)
{
	for(int i=0 ; i< RUINA_STORM_WEAVER_LENGHT ; i++)
	{
		int Tail = EntRefToEntIndex(i_segment_id[npc.index][i]);
		CClotBody tail = view_as<CClotBody>(Tail);
		tail.m_bDissapearOnDeath = true;	
		RequestFrame(KillNpc, EntIndexToEntRef(tail.index));
	}
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

	if(dist2>(150.0))	//just force teleport in these cases
	{
		TeleportEntity(npc.index, loc, NULL_VECTOR, NULL_VECTOR);
		return;
	}

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
	TeleportEntity(npc.index, NULL_VECTOR, vecView, NULL_VECTOR);
	if(!Los)
		npc.SetVelocity(vecVel);
	else
	{
		GetAngleVectors(vecView, vecFwd, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(vecFwd, speed);
		AddVectors(loc, vecFwd, loc);
		TeleportEntity(npc.index, loc, vecView, NULL_VECTOR);
	}
		
}
public int Storm_Weaver_Return_Health()
{
	return i_storm_weaver_health;
}
static void Storm_Weaver_Pulse_Solo_Mode(Storm_Weaver npc)
{
	for(int i= 0 ; i <= 8 ; i++)
	{
		if(i_magia_anchors_active < 4)
		{
			Storm_Weaver_Force_Spawn_Anchors(npc);
		}	
	}


	if(i_magia_anchors_active>=4)
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

	Handle ToGroundTrace = TR_TraceRayFilterEx(AproxRandomSpaceToWalkTo, view_as<float>( { 90.0, 0.0, 0.0 } ), npc.GetSolidMask(), RayType_Infinite, BulletAndMeleeTrace, npc.index);
		
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
		
	float flDistanceToBuild = GetVectorDistance(AproxRandomSpaceToWalkTo, WorldSpaceCenter(npc.index), true);
		
	float range = 250.0*i_magia_anchors_active;
	if(flDistanceToBuild < (range * range))
	{
		return; //The building is too close, we want to retry! it is unfair otherwise.
	}
	//Retry.


	float Health = float(GetEntProp(npc.index, Prop_Data, "m_iHealth"))+1.0;
	Health *=0.25;
	int spawn_index = Npc_Create(RUINA_MAGIA_ANCHOR, -1, AproxRandomSpaceToWalkTo, {0.0,0.0,0.0}, GetEntProp(npc.index, Prop_Send, "m_iTeamNum") == 2);
	if(spawn_index > MaxClients)
	{
		if(!b_IsAlliedNpc[npc.index])
		{
			Zombies_Currently_Still_Ongoing += 1;
		}
		fl_ruina_battery[spawn_index]=255.0;	//force spawn them fully
		SetEntityRenderMode(spawn_index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(spawn_index, 255, 255, 255, 1);

		int i_health = RoundToFloor(Health);
		SetEntProp(spawn_index, Prop_Data, "m_iHealth", i_health);
		SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", i_health);
	}
}

static int Storm_Weaver_Health()
{
	int anchor_id[RUINA_ANCHOR_HARD_LIMIT+1]; Find_Anchors(anchor_id);

	int health;
	for(int anchor=0 ; anchor <= RUINA_ANCHOR_HARD_LIMIT ; anchor++ )
	{
		int Anchor_Id = anchor_id[anchor];
		if(IsEntityAlive(Anchor_Id) && !b_NpcIsInvulnerable[Anchor_Id])
		{
			health+=GetEntProp(Anchor_Id, Prop_Data, "m_iHealth");
		}
	}
	return health+1;
}

static void Find_Anchors(int array[RUINA_ANCHOR_HARD_LIMIT+1])
{
	int anchor_current=0;
	for(int targ; targ<i_MaxcountNpc; targ++)
	{
		int baseboss_index = EntRefToEntIndex(i_ObjectsNpcs[targ]);
		if (IsValidEntity(baseboss_index) && !b_NpcHasDied[baseboss_index])
		{
			if(i_NpcInternalId[baseboss_index] == RUINA_MAGIA_ANCHOR)
			{
				array[anchor_current]=baseboss_index;
				anchor_current++;
			}
		}
	}
}
public void Storm_Weaver_Share_With_Anchor_Damage(int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{
	if(damagetype & DMG_CLUB)	//if a person is brave enough to melee this thing, reward them handsomely
	{
		damage *=2.5;
	}
	else	//otherwise...
	{
		damage *= 0.75;
	}

	if(i_magia_anchors_active<=0)
	{
		return;
	}

	int anchor_id[RUINA_ANCHOR_HARD_LIMIT+1]; Find_Anchors(anchor_id);

	if(attacker>MAXTF2PLAYERS)
	{
		float ratio = damage / i_magia_anchors_active;
		for(int anchor=0 ; anchor <= RUINA_ANCHOR_HARD_LIMIT ; anchor++ )
		{
			int Anchor_Id = anchor_id[anchor];
			if(IsEntityAlive(Anchor_Id) && !b_NpcIsInvulnerable[Anchor_Id])
			{
				SDKHooks_TakeDamage(Anchor_Id, attacker, inflictor, ratio, damagetype, weapon, damageForce, damagePosition, false, ZR_DAMAGE_NOAPPLYBUFFS_OR_DEBUFFS);
			}
		}
		return;
	}

	if(i_storm_weaver_damage_instance[attacker]>=RUINA_DAMAGE_INSTANCES_PER_FRAME)
		return;

	i_storm_weaver_damage_instance[attacker]++;

	float ratio = damage / i_magia_anchors_active;
	for(int anchor=0 ; anchor <= RUINA_ANCHOR_HARD_LIMIT ; anchor++ )
	{
		int Anchor_Id = anchor_id[anchor];
		if(IsEntityAlive(Anchor_Id) && !b_NpcIsInvulnerable[Anchor_Id])
		{
			SDKHooks_TakeDamage(Anchor_Id, attacker, inflictor, ratio, damagetype, weapon, damageForce, damagePosition, false, ZR_DAMAGE_NOAPPLYBUFFS_OR_DEBUFFS);
			RequestFrame(Nulify_Instance, attacker);
		}
	}
}
static void Nulify_Instance(int client)
{
	i_storm_weaver_damage_instance[client]=0;
}

static void Storm_Weaver_Damage_Touch(int entity, int other)
{
	if(IsValidEnemy(entity, other, true, true)) //Must detect camo.
	{
		if(fl_recently_teleported[entity]<GetGameTime())
			SDKHooks_TakeDamage(other, entity, entity, 100.0*RaidModeScaling, DMG_CRUSH, -1, _);
	}
}

static void Teleport_To_Random_Anchor(Storm_Weaver npc)
{
	int anchor_id[RUINA_ANCHOR_HARD_LIMIT+1]; Find_Anchors(anchor_id);

	int target = anchor_id[GetRandomInt(1 , RUINA_ANCHOR_HARD_LIMIT)];

	float Entity_Loc[3];
	GetEntPropVector(target, Prop_Send, "m_vecOrigin", Entity_Loc);
	Entity_Loc[2]+=150.0;
	bool Succeed = NPC_Teleport(npc.index, Entity_Loc);
	if(Succeed)
	{
		ParticleEffectAt(Entity_Loc, "eyeboss_death_vortex", 5.0);
		fl_teleporting_time[npc.index]=0.0;
		Set_Tail_Dist_To_Keep(npc, 25.0);
	}
}

static void Set_Tail_Dist_To_Keep(Storm_Weaver npc, float dist)
{
	for(int i=0 ; i< RUINA_STORM_WEAVER_LENGHT ; i++)
	{
		int Tail = EntRefToEntIndex(i_segment_id[npc.index][i]);
		fl_distance_to_keep[Tail] = dist;
	}
}
/*
static void Set_Tail_And_Head_Collision(Storm_Weaver npc, bool state)
{
	//int type;
	//if(state)
	//	type =24;
	//else
	//	type = 6;

	//SetEntityCollisionGroup(npc.index, type);
	b_CantCollidie[npc.index]=state;
	for(int i=0 ; i< RUINA_STORM_WEAVER_LENGHT ; i++)
	{
		int Tail = EntRefToEntIndex(i_segment_id[npc.index][i]);
		if (IsValidEntity(Tail) && !b_NpcHasDied[Tail])
		{
			b_CantCollidie[Tail]=state;
			//SetEntityCollisionGroup(Tail, type);
		}
	}
}*/

//TODO 
//Rewrite
public void Storm_Weaver_ClotThink(int iNPC)
{
	Storm_Weaver npc = view_as<Storm_Weaver>(iNPC);
	

	float GameTime = GetGameTime(npc.index);

	if(fl_recently_teleported[npc.index] < GameTime)
		ResolvePlayerCollisions_Npc(iNPC, /*damage crush*/ 10.0);

	if(npc.m_flNextDelayTime > GameTime)
	{
		return;
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
	}

	if(b_storm_weaver_solo)
	{
		Storm_Weaver_Pulse_Solo_Mode(npc);
	}
	else
	{
		if(i_magia_anchors_active<=0)
		{
			npc.m_bDissapearOnDeath = true;	
			RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
		}
		int Health = Storm_Weaver_Health();
		SetEntProp(npc.index, Prop_Data, "m_iHealth", Health);
	}
	int PrimaryThreatIndex = npc.m_iTarget;

	bool teleporting=false;
	if(fl_cantseetimeout[npc.index]<GameTime)	//we haven't been able to refind a proper target in 10 seconds, retreat to an anchor
	{
		fl_cantseetimeout[npc.index] = GameTime+RUINA_CANTSEE_TIMEOUT+2.5;
		float npc_vec[3]; npc_vec = GetAbsOrigin(npc.index);
		npc_vec[2] -= 25.0;
		ParticleEffectAt(npc_vec, "eyeboss_tp_vortex", 5.0);
		fl_teleport_time[npc.index]= GameTime+5.0;
		fl_teleporting_time[npc.index] = GameTime +7.5;
		Set_Tail_Dist_To_Keep(npc, 1.0);
	}
	if(fl_teleport_time[npc.index]>GameTime)
	{
		npc.SetVelocity({0.0, 0.0, 0.0});
		teleporting=true;
	}
	if(fl_teleporting_time[npc.index]>GameTime && fl_teleport_time[npc.index] < GameTime)
	{
		Teleport_To_Random_Anchor(npc);
	}

	if(teleporting)
		return; 
	else
		Set_Tail_Dist_To_Keep(npc, 25.0);

	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		Storm_Weaver_Heading_Control(npc, PrimaryThreatIndex, GameTime);
		
		int Enemy_I_See;
				
		Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
		//Target close enough to hit
		if(IsValidEnemy(npc.index, Enemy_I_See)) //Check if i can even see.
		{
			float flDistanceToTarget, vecTarget[3];
			vecTarget = WorldSpaceCenter(PrimaryThreatIndex);

			flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
			if(GameTime > npc.m_flNextRangedAttack)
			{
				npc.PlayMeleeHitSound();
				float projectile_speed = 1250.0;
				//lets pretend we have a projectile.
				if(flDistanceToTarget < 1250.0*1250.0)
					vecTarget = PredictSubjectPositionForProjectiles(npc, PrimaryThreatIndex, projectile_speed, 40.0);

				if(!Can_I_See_Enemy_Only(npc.index, PrimaryThreatIndex)) //cant see enemy in the predicted position, we will instead just attack normally
				{
					vecTarget = WorldSpaceCenter(PrimaryThreatIndex);
				}
				float DamageDone = 15.0*RaidModeScaling;
				npc.FireParticleRocket(vecTarget, DamageDone, projectile_speed, 0.0, "spell_fireball_small_blue", false, true, false,_,_,_,10.0);
				npc.m_flNextRangedAttack = GameTime + 1.1;
			}
		}
	}
	else	//random-ish wandering
	{
		if(!b_storm_weaver_solo)
		{
			float Npc_Vec[3]; Npc_Vec=GetAbsOrigin(npc.index);
			if(npc.m_flNextMeleeAttack < GameTime)
			{
				
				int anchor_id[RUINA_ANCHOR_HARD_LIMIT+1]; Find_Anchors(anchor_id);

				for(int anchor=0 ; anchor <= RUINA_ANCHOR_HARD_LIMIT ; anchor++ )
				{
					int Anchor_Id = anchor_id[anchor];
					if(IsEntityAlive(Anchor_Id))
					{
						float target_vec[3]; target_vec = GetAbsOrigin(Anchor_Id);
						float Distance=GetVectorDistance(Npc_Vec, target_vec, true);
						if(Distance>(250.0*250.0))
						{
							npc.m_flNextMeleeAttack = GameTime + 5.0;
							i_traveling_to_anchor[npc.index] = EntIndexToEntRef(Anchor_Id);
						}
					}
				}
			}
			else
			{
				int Anchor_Id = EntRefToEntIndex(i_traveling_to_anchor[npc.index]);
				if(IsValidEntity(Anchor_Id))
				{
					float target_vec[3]; target_vec = GetAbsOrigin(Anchor_Id);
					float Distance=GetVectorDistance(Npc_Vec, target_vec, true);
					if(Distance<(250.0*250.0))
					{
						npc.m_flNextMeleeAttack = 0.0;
					}
				}
			}

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
static void Storm_Weaver_Heading_Control(Storm_Weaver npc, int Target, float GameTime)
{
	float Npc_Vec[3]; Npc_Vec=GetAbsOrigin(npc.index);


	if(IsValidEnemy(npc.index, Target))
	{
		int New_Target = Storm_Weaver_Get_Target(npc);	//warp
		bool noclip=false;
		if(!IsValidEntity(New_Target))
		{
			/*npc.m_flSpeed = 250.0;
			b_NoGravity[npc.index] = false;
			npc.m_flGetClosestTargetTime = 0.0;
			
			float vecTarget[3]; vecTarget = WorldSpaceCenter(Target);
		
			float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);

			if(flDistanceToTarget < npc.GetLeadRadius()) 
			{
									
				float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, Target);
							
				NPC_SetGoalVector(npc.index, vPredictedPos);
			}
			else 
			{
				NPC_SetGoalEntity(npc.index, Target);
			}
			npc.StartPathing();
			npc.m_bPathing = true;

			return;*/
			noclip=true;
			New_Target = Target;
		}
		else
		{
			fl_cantseetimeout[npc.index] = GameTime + RUINA_CANTSEE_TIMEOUT;
		}

		if(npc.IsOnGround())
		{
			Npc_Vec[2] += 50.0;
			TeleportEntity(npc.index, Npc_Vec, NULL_VECTOR, NULL_VECTOR); 
		}
		b_NoGravity[npc.index] = true;	//Found ya!

		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;

		float target_vec[3], flDistanceToTarget; target_vec = GetAbsOrigin(New_Target);

		flDistanceToTarget = GetVectorDistance(target_vec, Npc_Vec, true);

		if(flDistanceToTarget>(150.0*150.0))
			target_vec[2]+=135.0;
		else
			target_vec[2]+=75.0;

		if(!noclip)
			Storm_Weaver_Fly(npc, target_vec);
		else
		{
			fl_recently_teleported[npc.index] = GameTime + 2.5;
			float distance = RUINA_STORM_WEAVER_NOCLIP_SPEED;
			if(flDistanceToTarget<(distance*distance))
			{
				target_vec[2]-=40.0;
				Storm_Weaver_Noclip(npc, target_vec, GetVectorDistance(target_vec, Npc_Vec));
			}
			else
			{
				Storm_Weaver_Noclip(npc, target_vec, distance);
			}
				
		}
			


	}
	else
	{
		float target_vec[3]; target_vec = GetAbsOrigin(Target);
		int I_see=Can_I_See_Ally(npc.index, Target);
		if(I_see==Target)
		{
			fl_cantseetimeout[npc.index] = GameTime + RUINA_CANTSEE_TIMEOUT;
			Storm_Weaver_Fly(npc, target_vec);
		}
		else
		{
			Storm_Weaver_Noclip(npc, target_vec);
		}
			
	}
}
static int i_force_teleport[MAXENTITIES];
static void Storm_Weaver_Noclip(Storm_Weaver npc, float target_vec[3], float distance = RUINA_STORM_WEAVER_NOCLIP_SPEED)
{
	float Direction[3], vecAngles[3], npc_vec[3];
	npc_vec=GetAbsOrigin(npc.index);

	float Speed = distance;

	float result_vec[3];

	MakeVectorFromPoints(npc_vec, target_vec, vecAngles);
	GetVectorAngles(vecAngles, vecAngles);
							
	GetAngleVectors(vecAngles, Direction, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(Direction, Speed);
	AddVectors(npc_vec, Direction, result_vec);

	if(i_force_teleport[npc.index]>=10)
	{
		ParticleEffectAt(result_vec, "eyeboss_death_vortex", 0.1);
		i_force_teleport[npc.index]=0;
		TeleportEntity(npc.index, result_vec, vecAngles, NULL_VECTOR);
	}
	else
	{
		i_force_teleport[npc.index]++;
	}
}
static void Storm_Weaver_Fly(Storm_Weaver npc, float target_vec[3])
{
	float npc_vec[3]; npc_vec=GetAbsOrigin(npc.index);

	float newVel[3];
	
	GetEntPropVector(npc.index, Prop_Data, "m_vecVelocity", newVel);

	float vecAngles[3];
	MakeVectorFromPoints(npc_vec, target_vec, vecAngles);
	GetVectorAngles(vecAngles, vecAngles);

	TeleportEntity(npc.index, NULL_VECTOR, vecAngles, NULL_VECTOR);

	float max_speed = RUINA_STORM_WEAVER_FLIGHT_SPEED;

	for(int vec=0 ; vec <=2 ; vec++)
	{
		if(npc_vec[vec]<target_vec[vec])
		{
			if(Storm_Weaver_Check_Heading_Walls(npc, vec, 1))
			{
				newVel[vec] += 75.0;
			}
			else
			{
				newVel[vec] = 0.0;
			}
			//newVel[vec] += 75.0;
		}
		else
		{
			if(Storm_Weaver_Check_Heading_Walls(npc, vec, -1))
			{
				newVel[vec] -= 75.0;
			}
			else
			{
				newVel[vec] = 0.0;
			}
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
static bool Storm_Weaver_Check_Heading_Walls(Storm_Weaver npc, int vec, int type)
{
	
	float npc_vec[3]; npc_vec = GetAbsOrigin(npc.index);
	
	float tmp_vec[3]; tmp_vec = npc_vec;
	tmp_vec[vec] += 80.0 * type;
	float angles[3];
	
	MakeVectorFromPoints(npc_vec, tmp_vec, angles);
	GetVectorAngles(angles, angles);
		
	float ground_vec[3];
		
	Handle trace = TR_TraceRayFilterEx(npc_vec, angles, MASK_SHOT, RayType_Infinite, BulletAndMeleeTrace, npc.index);
	if (TR_DidHit(trace))
	{
		TR_GetEndPosition(ground_vec, trace);
		delete trace;
		
		if(GetVectorDistance(npc_vec, ground_vec, true) <= (80.0*80.0))
		{
			return false;
		}
		else
		{
			return true;
		}
	}
	else
	{
		delete trace;
		return false;
	}
}
static int Storm_Weaver_Get_Target(Storm_Weaver npc)
{
	float npc_vec[3]; npc_vec = GetAbsOrigin(npc.index);
	float last_dist = 3333333.0;
	int closest_yet = -1;
	for(int entity=0 ; entity < MAXENTITIES ; entity++)
	{
		if(IsValidEntity(entity))
		{
			if(IsValidEnemy(npc.index, entity))
			{
				float vecTarget[3]; vecTarget = WorldSpaceCenter(entity);
		
				float flDistanceToTarget = GetVectorDistance(vecTarget, npc_vec, true);

				if(flDistanceToTarget < last_dist)
				{
					int Enemy_I_See;
						
					Enemy_I_See = Can_I_See_Enemy(npc.index, entity);
					//Target close enough to hit
					if(IsValidEnemy(npc.index, Enemy_I_See)) //Check if i can even see.
					{
						last_dist=flDistanceToTarget;
						closest_yet=Enemy_I_See;
					}
				}
			}
		}
	}
	return closest_yet;
}
public Action Storm_Weaver_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Storm_Weaver npc = view_as<Storm_Weaver>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if(!b_storm_weaver_solo)
	{
		Storm_Weaver_Share_With_Anchor_Damage(attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition);
		fl_ruina_battery[npc.index] += damage;	//turn damage taken into energy
		damage=0.0;	//storm weaver doesn't really take any damage, his "health bar" is just the combined health of all the towers

		//int Health = Storm_Weaver_Health();
		//SetEntProp(npc.index, Prop_Data, "m_iHealth", Health);
	}
	else
	{
		if(damagetype & DMG_CLUB)	//if a person is brave enough to melee this thing, reward them handsomely
		{
			damage *=2.5;
			fl_ruina_battery[npc.index] += damage;	//turn damage taken into energy
		}
	}
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void Storm_Weaver_NPCDeath(int entity)
{
	Storm_Weaver npc = view_as<Storm_Weaver>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}

	RaidBossActive = INVALID_ENT_REFERENCE;
	
	Storm_Weaver_Nuke_Tail(npc);
	
	SDKUnhook(npc.index, SDKHook_Think, Storm_Weaver_ClotThink);

}