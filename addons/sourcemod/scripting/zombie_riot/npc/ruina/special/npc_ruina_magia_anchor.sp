#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	")physics/metal/metal_canister_impact_hard1.wav",
	")physics/metal/metal_canister_impact_hard2.wav",
	")physics/metal/metal_canister_impact_hard3.wav",
};

static const char g_HurtSounds[][] = {
	")physics/metal/metal_box_impact_bullet1.wav",
	")physics/metal/metal_box_impact_bullet2.wav",
	")physics/metal/metal_box_impact_bullet3.wav",
};

static const char g_IdleSounds[][] = {
	"npc/metropolice/vo/affirmative.wav",
	"npc/metropolice/vo/affirmative2.wav",
	"npc/metropolice/vo/canalblock.wav",
	"npc/metropolice/vo/chuckle.wav",
	"npc/metropolice/vo/citizen.wav",
	"npc/metropolice/vo/code7.wav",
	"npc/metropolice/vo/code100.wav",
	"npc/metropolice/vo/copy.wav",
	"npc/metropolice/vo/breakhiscover.wav",
	"npc/metropolice/vo/help.wav",
	"npc/metropolice/vo/hesgone148.wav",
	"npc/metropolice/vo/hesrunning.wav",
	"npc/metropolice/vo/infection.wav",
	"npc/metropolice/vo/king.wav",
	"npc/metropolice/vo/needanyhelpwiththisone.wav",

	"npc/metropolice/vo/pickupthecan2.wav",
	"npc/metropolice/vo/sociocide.wav",
	"npc/metropolice/vo/watchit.wav",
	"npc/metropolice/vo/xray.wav",
	"npc/metropolice/vo/youknockeditover.wav",
};

static const char g_IdleAlertedSounds[][] = {
	"npc/metropolice/vo/affirmative.wav",
	"npc/metropolice/vo/affirmative2.wav",
	"npc/metropolice/vo/canalblock.wav",
	"npc/metropolice/vo/chuckle.wav",
	"npc/metropolice/vo/citizen.wav",
	"npc/metropolice/vo/code7.wav",
	"npc/metropolice/vo/code100.wav",
	"npc/metropolice/vo/copy.wav",
	"npc/metropolice/vo/breakhiscover.wav",
	"npc/metropolice/vo/help.wav",
	"npc/metropolice/vo/hesgone148.wav",
	"npc/metropolice/vo/hesrunning.wav",
	"npc/metropolice/vo/infection.wav",
	"npc/metropolice/vo/king.wav",
	"npc/metropolice/vo/needanyhelpwiththisone.wav",
	"npc/metropolice/vo/pickupthecan1.wav",

	"npc/metropolice/vo/pickupthecan3.wav",
	"npc/metropolice/vo/sociocide.wav",
	"npc/metropolice/vo/watchit.wav",
	"npc/metropolice/vo/xray.wav",
	"npc/metropolice/vo/youknockeditover.wav",
	"npc/metropolice/takedown.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/cleaver_hit_02.wav",
	"weapons/cleaver_hit_03.wav",
	"weapons/cleaver_hit_05.wav",
	"weapons/cleaver_hit_06.wav",
	"weapons/cleaver_hit_07.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/bow_shoot.wav",
};

static const char g_MeleeMissSounds[][] = {
	"weapons/draw_sword.wav",
};

bool b_is_magia_tower[MAXENTITIES];

#define RUINA_TOWER_CORE_MODEL "models/props_urban/urban_skybuilding005a.mdl"
#define RUINA_TOWER_CORE_MODEL_SIZE "0.75"
#define RUINA_ANCHOR_MODEL	"models/props_combine/combine_citadel001.mdl"
#define RUINA_ANCHOR_MODEL_SIZE "0.075"

bool b_stellar_weaver_summoned;
static int i_currentwave[MAXENTITIES];
//static float f_PlayerScalingBuilding;
static int Heavens_Beam;

#define MAGIA_ANCHOR_MAX_IONS 4

static float fl_Heavens_Loc[MAXENTITIES][MAGIA_ANCHOR_MAX_IONS+1][3];
static float fl_Heavens_Target_Loc[MAXENTITIES][MAGIA_ANCHOR_MAX_IONS+1][3];
static bool b_targeted_by_heavens[MAXTF2PLAYERS+1];
static float fl_was_targeted[MAXTF2PLAYERS+1];
static float fl_heavens_rng_loc_timer[MAXENTITIES][MAGIA_ANCHOR_MAX_IONS+1];
static int i_heavens_target_id[MAGIA_ANCHOR_MAX_IONS+1];

void Magia_Anchor_OnMapStart_NPC()
{
	Zero(b_is_magia_tower);

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Magia Anchor");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_ruina_magia_anchor");
	data.Category = Type_Ruina;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	strcopy(data.Icon, sizeof(data.Icon), "tower"); 						//leaderboard_class_(insert the name)
	data.IconCustom = true;												//download needed?
	data.Flags = MVM_CLASS_FLAG_ALWAYSCRIT;						//example: MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;, forces these flags.	
	NPC_Add(data);
}
static void ClotPrecache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_MeleeMissSounds);
	PrecacheModel(RUINA_ANCHOR_MODEL);
	PrecacheModel(RUINA_TOWER_CORE_MODEL);
	Heavens_Beam = PrecacheModel(BLITZLIGHT_SPRITE);
}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return Magia_Anchor(client, vecPos, vecAng, ally);
}
methodmap Magia_Anchor < CClotBody
{
	public void PlayIdleSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);

	}
	
	public void PlayIdleAlertSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);

	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);

	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		
	}
	
	public void PlayMeleeSound() 
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		
	}
	
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		

	}

	public void PlayMeleeMissSound() 
	{
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		
	}
	
	public Magia_Anchor(int client, float vecPos[3], float vecAng[3], int ally)
	{
		Magia_Anchor npc = view_as<Magia_Anchor>(CClotBody(vecPos, vecAng, RUINA_TOWER_CORE_MODEL, RUINA_TOWER_CORE_MODEL_SIZE, "10000", ally, false,true,_,_,{30.0,30.0,350.0}));
		
		i_NpcWeight[npc.index] = 999;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");

		b_is_magia_tower[npc.index]=true;

		npc.m_iWearable1 = npc.EquipItemSeperate("partyhat", RUINA_ANCHOR_MODEL, _, _, _, 225.0);
		SetVariantString(RUINA_ANCHOR_MODEL_SIZE);
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		/*npc.m_iWearable2 = npc.EquipItemSeperate("partyhat", "models/props_borealis/bluebarrel001.mdl");
		SetVariantString("2.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");*/

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_bDissapearOnDeath = true;

		Ruina_Set_Sniper_Anchor_Point(npc.index, true);

		i_magia_anchors_active++;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;
		if(ally != TFTeam_Red)
		{
			b_thisNpcIsABoss[npc.index] = true;
		}
		i_NpcIsABuilding[npc.index] = true;

		float wave = float(ZR_GetWaveCount()+1);
		
		wave *= 0.1;
	
		npc.m_flWaveScale = wave;

		b_ThisNpcIsImmuneToNuke[npc.index] = true;

		//f_PlayerScalingBuilding = float(CountPlayersOnRed());

		i_currentwave[npc.index] = (ZR_GetWaveCount()+1);

		func_NPCDeath[npc.index] = view_as<Function>(NPC_Death);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(ClotThink);

		GiveNpcOutLineLastOrBoss(npc.index, true);
		

		Ruina_Set_Heirarchy(npc.index, RUINA_RANGED_NPC);	//is a ranged npc. in this case its to allow buffing logic to work on it, thats it

		Ruina_Set_No_Retreat(npc.index);
		Ruina_Set_Sniper_Anchor_Point(npc.index, true);

		npc.m_iState = 0;
		npc.m_flSpeed = 0.0;
		
		npc.m_flMeleeArmor = 2.5;
		npc.m_flRangedArmor = 1.0;

		NPC_StopPathing(npc.index);

		return npc;
	}
}

static void ClotThink(int iNPC)
{
	Magia_Anchor npc = view_as<Magia_Anchor>(iNPC);

	float GameTime = GetGameTime(npc.index);
/*
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();	
*/
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
	
	if(fl_ruina_battery[npc.index]<=255)	//charging phase
	{
	
		Ruina_Add_Battery(npc.index, 0.5);	//the anchor has the ability to build itself, but it stacks with the builders
		int alpha = RoundToFloor(fl_ruina_battery[npc.index]);
		if(alpha > 255)
		{
			alpha = 255;
		}
		//PrintToChatAll("Alpha: %i", alpha);
		SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, alpha);

	//	SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
	//	SetEntityRenderColor(npc.m_iWearable2, 255, 255, 255, alpha);
		
	}
	else	//active phase. unlike villager's building, they won't commit sudoku if the builder dies
	{
		for(int player=0 ; player <=MAXTF2PLAYERS ; player++)
		{
			if(fl_was_targeted[player]< GameTime)	//make it so heavens light doesn't just target 1 singular player making 1 beam of fucking death and destruction thats really bright
			{
				b_targeted_by_heavens[player]=false;
			}
		}

		int wave = ZR_GetWaveCount()+1;

		int amt = 1;
		if(wave<=15)
		{
			amt = 1;
		}
		else if(wave <=30)
		{
			amt = 2;
		}
		else if(wave <=45)
		{
			amt = 3;
		}
		else
		{
			amt = MAGIA_ANCHOR_MAX_IONS;
		}

		Heavens_Full_Charge(npc, amt, 250.0, 100.0, 12.5);

		if(npc.m_flNextMeleeAttack < GameTime)
		{
			int Target;
			Target = GetClosestTarget(npc.index);
			if(IsValidEnemy(npc.index, Target))
			{
				npc.m_flNextMeleeAttack = GameTime + 5.0;
			}
		}

		if(i_magia_anchors_active>=4)
		{
			if(!b_stellar_weaver_summoned)
			{
				Summon_Stellar_Weaver(npc);
			}
		}
	}
	if(fl_ruina_battery[npc.index]<300 && fl_ruina_battery[npc.index]>=254) 
	{
		SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 255);
		SetEntityRenderMode(npc.m_iWearable1, RENDER_NORMAL);
	//	SetEntityRenderColor(npc.m_iWearable2, 255, 255, 255, 255);
	//	SetEntityRenderMode(npc.m_iWearable2, RENDER_NORMAL);
		fl_ruina_battery[npc.index]=333.0;

		float Npc_Loc[3]; GetAbsOrigin(npc.index, Npc_Loc);

		for(int i=0 ; i <MAGIA_ANCHOR_MAX_IONS ; i++)
		{

			fl_Heavens_Loc[npc.index][i] = Npc_Loc;
		}
	}

}

static void Summon_Stellar_Weaver(Magia_Anchor npc)
{
	float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
	float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
	int maxhealth;

	maxhealth = GetEntProp(npc.index, Prop_Data, "m_iHealth");
	
	maxhealth = RoundToFloor(maxhealth*1.5);
	float Npc_Loc[3]; GetAbsOrigin(npc.index, Npc_Loc);
	int spawn_index = NPC_CreateByName("npc_ruina_stellar_weaver", npc.index, Npc_Loc, ang, GetTeam(npc.index));
	if(spawn_index > MaxClients)
	{
		if(GetTeam(npc.index) != TFTeam_Red)
		{
			NpcAddedToZombiesLeftCurrently(spawn_index, true);
		}
		SetEntProp(spawn_index, Prop_Data, "m_iHealth", maxhealth);
		SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", maxhealth);
	}
}

static Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	Magia_Anchor npc = view_as<Magia_Anchor>(victim);

	Ruina_NPC_OnTakeDamage_Override(npc.index, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);

	if(fl_ruina_battery[npc.index] <=200.0)
		Ruina_Add_Battery(npc.index, 0.5);	//anchor gets charge every hit. :)
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	return Plugin_Changed;
}

static void NPC_Death(int entity)
{
	Magia_Anchor npc = view_as<Magia_Anchor>(entity);
	npc.PlayDeathSound();	
	float pos[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
	makeexplosion(-1, -1, pos, "", 0, 0);

	b_is_magia_tower[npc.index]=false;
	i_magia_anchors_active--;

	Ruina_NPCDeath_Override(entity);
		
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
}

static void Heavens_Full_Charge(Magia_Anchor npc, int amt, float Radius, float aDamage, float Speed)	//rewerite this: to use a env_beam rather then TE, and also to make it prefer attacking other people then singular targets
{
	float GameTime = GetGameTime();
	for(int i=0 ; i< amt ; i++)
	{
		float loc[3]; loc = fl_Heavens_Loc[npc.index][i];
		float Target_Loc[3]; Target_Loc = loc;

		int Target = HeavenLight_GetTarget(i, loc);	//get a target if we can
		

		if(IsValidClient(Target))	//we got a target, get his ass's loc so we can roast him
		{
			GetEntPropVector(Target, Prop_Data, "m_vecAbsOrigin", Target_Loc);
			fl_Heavens_Target_Loc[npc.index][i] = Target_Loc;
		}
		else	//we didn't get a loc, find a random loc to wander to
		{
			if(fl_heavens_rng_loc_timer[npc.index][i] < GameTime)
			{
				fl_heavens_rng_loc_timer[npc.index][i] = GameTime+GetRandomFloat(1.0, 5.0);	//make it so we don't constantly check nav mesh 10 billion times a second
				GetRandomLoc(npc, Target_Loc, i);
				fl_Heavens_Target_Loc[npc.index][i] = Target_Loc;
			}
			else
			{
				Target_Loc = fl_Heavens_Target_Loc[npc.index][i];
			}
			
		}
		
		float Direction[3], vecAngles[3];
		MakeVectorFromPoints(loc, Target_Loc, vecAngles);
		GetVectorAngles(vecAngles, vecAngles);
						
		GetAngleVectors(vecAngles, Direction, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(Direction, Speed);
		AddVectors(loc, Direction, loc);
		
		Ruina_Proper_To_Groud_Clip({24.0,24.0,24.0}, 300.0, loc);

		int wave = ZR_GetWaveCount()+1;

		int color[4];
		color[3] = 75;
		

		if(wave<=15)
		{
			color[0] = 255;
			color[1] = 50;
			color[2] = 50;
		}
		else if(wave <=30)
		{
			color[0] = 147;
			color[1] = 188;
			color[2] = 199;
		}
		else if(wave <=45)
		{
			color[0] = 51;
			color[1] = 9;
			color[2] = 235;
		}
		else
		{
			color[0] = 0;
			color[1] = 250;
			color[2] = 237;
		}

		
		
		fl_Heavens_Loc[npc.index][i] = loc;

		Heavens_SpawnBeam(loc, color, 7.5, true, Radius);

		Ruina_AOE_Add_Mana_Sickness(loc, npc.index, Radius, 0.01, 2);

		Explode_Logic_Custom(aDamage, npc.index, npc.index, -1, loc, Radius , _ , _ , true, _, _, 2.5);
	}
}
static void Heavens_SpawnBeam(float beamLoc[3], int color[4], float size, bool rings, float radius)
{
	float skyLoc[3], groundLoc[3];
	skyLoc[0] = beamLoc[0];
	skyLoc[1] = beamLoc[1];
	skyLoc[2] = 9999.0;
	groundLoc = beamLoc;
	groundLoc[2] -= 200.0;


	TE_SetupBeamPoints(skyLoc, groundLoc, Heavens_Beam, Heavens_Beam, 0, 1, 0.1, size, size, 1, 0.5, color, 1);
	TE_SendToAll();

	if(rings)
		spawnRing_Vector(beamLoc, radius*2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", color[0], color[1], color[2], color[3], 1, 0.1, 1.0, 0.1, 1);
}
static void GetRandomLoc(Magia_Anchor npc, float Loc[3], int Num)	//directly stolen and modified from villagers building spawn code :3
{

	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", Loc);

	Loc[0] = GetRandomFloat((Loc[0] - 200.0*Num),(Loc[0] + 200.0*Num));
	Loc[1] = GetRandomFloat((Loc[1] - 200.0*Num),(Loc[1] + 200.0*Num));

	Handle ToGroundTrace = TR_TraceRayFilterEx(Loc, view_as<float>( { 90.0, 0.0, 0.0 } ), GetSolidMask(npc.index), RayType_Infinite, BulletAndMeleeTrace, npc.index);
		
	TR_GetEndPosition(Loc, ToGroundTrace);
	delete ToGroundTrace;

	CNavArea area = TheNavMesh.GetNearestNavArea(Loc, true);
	if(area == NULL_AREA)
	{
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", Loc);
		Loc[0] +=GetRandomFloat((-200.0*Num),(200.0*Num));
		Loc[1]  +=GetRandomFloat((-200.0*Num),(200.0*Num));
		return;
	}
		

	int NavAttribs = area.GetAttributes();
	if(NavAttribs & NAV_MESH_AVOID)
	{
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", Loc);
		Loc[0] +=GetRandomFloat((-200.0*Num),(200.0*Num));
		Loc[1]  +=GetRandomFloat((-200.0*Num),(200.0*Num));
		return;
	}
			

	area.GetCenter(Loc);
}
static int HeavenLight_GetTarget(int ID, float loc[3])	//get the closest valid target for the heavens light.
{
	float Dist = -1.0;
	int client_id=-1;
	for(int client=0 ; client <=MAXTF2PLAYERS ; client++)
	{
		if(IsValidClient(client) && IsClientInGame(client) && GetClientTeam(client) != 3 && IsEntityAlive(client) && TeutonType[client] == TEUTON_NONE && dieingstate[client] == 0)
		{
			if(!b_targeted_by_heavens[client] || client==i_heavens_target_id[ID])	//if the player is already targeted, ignore him. UNLESS, we are the ones who are targeting him, then add him to the distance calcs
			{
				float client_loc[3]; GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", client_loc);
				float distance = GetVectorDistance(client_loc, loc, true);
				{
					if(distance<Dist || Dist==-1.0)
					{
						Dist = distance;	//closest target is best target - idk.
						client_id = client;
					}
				}
			}
		}
	}
	if(IsValidClient(client_id))	// if the target is valid, we add a lock onto him
	{
		fl_was_targeted[client_id] = GetGameTime()+0.25;
		b_targeted_by_heavens[client_id]=true;
		i_heavens_target_id[ID]=client_id;
	}
	return client_id;	//and then we return the client id. This can often return -1, but thats intended and is dealt with
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