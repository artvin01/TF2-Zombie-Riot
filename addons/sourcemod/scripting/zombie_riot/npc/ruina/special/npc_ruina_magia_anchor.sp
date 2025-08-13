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
	"ui/hitsound_vortex1.wav",
	"ui/hitsound_vortex2.wav",
	"ui/hitsound_vortex3.wav",
	"ui/hitsound_vortex4.wav",
	"ui/hitsound_vortex5.wav"
};

float SpawnedOneAlready;
int IdRef;

static bool b_is_magia_tower[MAXENTITIES];
static bool b_allow_weaver[MAXENTITIES];
static float fl_weaver_charge[MAXENTITIES];
static int i_weaver_index[MAXENTITIES];
static int i_wave[MAXENTITIES];
static bool b_allow_spawns[MAXENTITIES];
static int i_special_tower_logic[MAXENTITIES];
static int i_current_cycle[MAXENTITIES];
static int i_strikes[MAXPLAYERS];

#define RUINA_TOWER_CORE_MODEL "models/props_urban/urban_skybuilding005a.mdl"
#define RUINA_TOWER_CORE_MODEL_SIZE "0.75"
static float f_PlayerScalingBuilding;
void Magia_Anchor_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Magia Anchor");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_ruina_magia_anchor");
	data.Category = Type_Ruina;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	strcopy(data.Icon, sizeof(data.Icon), "teleporter"); 						//leaderboard_class_(insert the name)
	data.IconCustom = false;												//download needed?
	data.Flags = MVM_CLASS_FLAG_ALWAYSCRIT;						//example: MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;, forces these flags.	
	NPC_Add(data);
}
static void ClotPrecache()
{
	Zero(b_is_magia_tower);
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_MeleeMissSounds);
	PrecacheModel(RUINA_TOWER_CORE_MODEL);
}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return Magia_Anchor(vecPos, vecAng, team, data);
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
	
	public Magia_Anchor(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Magia_Anchor npc = view_as<Magia_Anchor>(CClotBody(vecPos, vecAng, RUINA_TOWER_CORE_MODEL, RUINA_TOWER_CORE_MODEL_SIZE, MinibossHealthScaling(180.0), ally, false,true,_,_,{30.0,30.0,350.0}, .NpcTypeLogic = 1));
		
		i_NpcWeight[npc.index] = 999;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");

		b_is_magia_tower[npc.index]=true;

		SetEntityRenderMode(npc.index, RENDER_NONE);
		SetEntityRenderColor(npc.index, 255, 255, 255, 1);

		npc.m_iWearable1 = npc.EquipItemSeperate(RUINA_CUSTOM_MODELS_3);
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");


		int wave = Waves_GetRoundScale()+1;

		if(StrContains(data, "force10") != -1)
			wave = 10;
		if(StrContains(data, "force20") != -1)
			wave = 20;
		if(StrContains(data, "force30") != -1)
			wave = 30;
		if(StrContains(data, "force40") != -1)
			wave = 40;

		i_wave[npc.index] = wave;
		f_PlayerScalingBuilding = ZRStocks_PlayerScalingDynamic();

		fl_weaver_charge[npc.index] = 0.0;
		i_weaver_index[npc.index] = INVALID_ENT_REFERENCE;

		if(StrContains(data, "noweaver") != -1)
			b_allow_weaver[npc.index] = false;
		else
			b_allow_weaver[npc.index] = true;

		if(StrContains(data, "nospawns") != -1)
			b_allow_spawns[npc.index] = false;
		else
			b_allow_spawns[npc.index] = true;
		
		i_special_tower_logic[npc.index] = 0;

		if(StrContains(data, "lelouch") != -1)
			i_special_tower_logic[npc.index] = 1;
		
		if(StrContains(data, "raid") != -1)
			i_RaidGrantExtra[npc.index] = RAIDITEM_INDEX_WIN_COND;

		i_current_cycle[npc.index] = 0;
		
		//whats a "switch" statement??
		if(wave<=10)	
		{
			SetVariantInt(RUINA_MAGIA_TOWER_1);
			AcceptEntityInput(npc.m_iWearable1, "SetBodyGroup");
		}
		else if(wave <=20)	
		{
			SetVariantInt(RUINA_MAGIA_TOWER_2);
			AcceptEntityInput(npc.m_iWearable1, "SetBodyGroup");
		}
		else if(wave <= 30)	
		{
			SetVariantInt(RUINA_MAGIA_TOWER_3);
			AcceptEntityInput(npc.m_iWearable1, "SetBodyGroup");
		}
		else
		{
			SetVariantInt(RUINA_MAGIA_TOWER_4);						//tier 4 gregification beacon
			AcceptEntityInput(npc.m_iWearable1, "SetBodyGroup");
		}

		if(!IsValidEntity(RaidBossActive) && b_allow_weaver[npc.index])
		{
			RaidModeTime = FAR_FUTURE;

			RaidBossActive = EntIndexToEntRef(npc.index);
			RaidAllowsBuildings = true;

			RaidModeScaling = 0.0;
		
		}

		fl_ruina_battery[npc.index] = 0.0;

		bool full = StrContains(data, "full") != -1;

		if(full)
		{
			fl_ruina_battery[npc.index] = 255.0;
		}

		Zero(i_strikes);

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_bDissapearOnDeath = true;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;
		if(ally != TFTeam_Red)
		{
			b_thisNpcIsABoss[npc.index] = true;
		}
		i_NpcIsABuilding[npc.index] = true;
	
		//npc.m_flWaveScale = wave;

		b_ThisNpcIsImmuneToNuke[npc.index] = true;

		func_NPCDeath[npc.index] = view_as<Function>(NPC_Death);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(ClotThink);

		GiveNpcOutLineLastOrBoss(npc.index, true);

		Ruina_Set_Heirarchy(npc.index, RUINA_RANGED_NPC);	//is a ranged npc. in this case its to allow buffing logic to work on it, thats it

		Ruina_Set_No_Retreat(npc.index);
		Ruina_Set_Sniper_Anchor_Point(npc.index, true);

		npc.m_iState = 0;
		npc.m_flSpeed = 0.0;
		
		npc.m_flMeleeArmor = 1.0;
		npc.m_flRangedArmor = 1.0;
		npc.m_flAttackHappens = 0.0;

		npc.m_flMeleeArmor = 2.5;
		f_ExtraOffsetNpcHudAbove[npc.index] = 115.0;

		if(GetTeam(npc.index) != 2)
			SDKHook(npc.index, SDKHook_StartTouch, TowerDetectRiding);

		/*int test;
		test = GetEntProp(npc.index, Prop_Data, "m_usSolidFlags");
		CPrintToChatAll("m_usSolidFlags %i", test);
		test = GetEntProp(npc.index, Prop_Data, "m_nSolidType");
		CPrintToChatAll("m_nSolidType %i", test);
		*/
		return npc;
	}
}

static void TowerDetectRiding(int entity, int client)
{
	if(!IsValidClient(client))
		return;

	float Vec[3], vec2[3];
	WorldSpaceCenter(entity, Vec);
	Vec[2]+=20.0;
	WorldSpaceCenter(client, vec2);
	if(vec2[2] > Vec[2])	
	{
		//anihilate them immediately
		i_strikes[client]++;
		if(i_strikes[client]>0)
		{
			SDKHooks_TakeDamage(client, 0, 0, 199999999.0, DMG_BLAST, -1, _, _, _, ZR_SLAY_DAMAGE);
		}
		else
			CPrintToChat(client, "{red}GET OFF THE TOWER, STRIKE %i/2", i_strikes[client]);


		float newVel[3];
		
		newVel[0] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[0]");
		newVel[1] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[1]");
		newVel[2] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[2]");

		newVel[2] = 500.0;

		newVel[0] +=GetRandomFloat(-505.0, 505.0);
		newVel[1] +=GetRandomFloat(-505.0, 505.0);
		
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, newVel);
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
	if(!npc.m_flAttackHappens)
	{
		npc.m_flAttackHappens = FAR_FUTURE;
		
		float VecSelfNpcabs[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", VecSelfNpcabs);
		VecSelfNpcabs[2] += 100.0;
		if(GetTeam(npc.index) == TFTeam_Red)
		{
			Event event = CreateEvent("show_annotation");
			if(event)
			{
				event.SetFloat("worldPosX", VecSelfNpcabs[0]);
				event.SetFloat("worldPosY", VecSelfNpcabs[1]);
				event.SetFloat("worldPosZ", VecSelfNpcabs[2]);
				event.SetFloat("lifetime", 7.0);
				event.SetString("text", "Allied Magia Anchors!");
				event.SetString("play_sound", "vo/null.mp3");
				IdRef++;
				event.SetInt("id", IdRef); //What to enter inside? Need a way to identify annotations by entindex!
				event.Fire();
			}
		}
		else if(SpawnedOneAlready > GetGameTime())
		{
			Event event = CreateEvent("show_annotation");
			if(event)
			{
				event.SetFloat("worldPosX", VecSelfNpcabs[0]);
				event.SetFloat("worldPosY", VecSelfNpcabs[1]);
				event.SetFloat("worldPosZ", VecSelfNpcabs[2]);
				event.SetFloat("lifetime", 7.0);
				event.SetString("text", "Multiple Magia Anchors!");
				event.SetString("play_sound", "vo/null.mp3");
				IdRef++;
				event.SetInt("id", IdRef); //What to enter inside? Need a way to identify annotations by entindex!
				event.Fire();
			}
		}
		else
		{
			Event event = CreateEvent("show_annotation");
			if(event)
			{
				event.SetFloat("worldPosX", VecSelfNpcabs[0]);
				event.SetFloat("worldPosY", VecSelfNpcabs[1]);
				event.SetFloat("worldPosZ", VecSelfNpcabs[2]);
				event.SetFloat("lifetime", 7.0);
				event.SetString("text", "Magia Anchor");
				event.SetString("play_sound", "vo/null.mp3");
				IdRef++;
				event.SetInt("id", IdRef); //What to enter inside? Need a way to identify annotations by entindex!
				event.Fire();
			}
			SpawnedOneAlready = GetGameTime() + 60.0;
		}
	}
	

	if(!IsValidEntity(RaidBossActive) && b_allow_weaver[npc.index])
	{
		RaidBossActive=EntIndexToEntRef(npc.index);
	}

	if(!Charging(npc))
		return;

	npc.m_flNextThinkTime = GameTime + 0.1;

	if(i_special_tower_logic[npc.index] == 1)
	{
		float Radius = 650.0;
		Master_Apply_Defense_Buff(npc.index, Radius, 20.0, 0.75);	//25% resistances
		Master_Apply_Attack_Buff(npc.index, Radius, 20.0, 0.25);		//25% dmg bonus

		float Npc_Vec[3]; GetAbsOrigin(npc.index, Npc_Vec); Npc_Vec[2]+=30.0;
		int color[4]; Ruina_Color(color);
		TE_SetupBeamRingPoint(Npc_Vec, Radius*2.0, Radius*2.0 + 0.5, g_Ruina_Laser_BEAM, g_Ruina_Laser_BEAM, 0, 1, 0.1, 12.0, 0.1, color, 1, 0);
		TE_SendToAll();
	}

	if(i_RaidGrantExtra[npc.index] == RAIDITEM_INDEX_WIN_COND)	//we are summoned by a raidboss, do custom stuff.
	{
		Raid_Spwaning_Logic(npc);
	}
	if(b_allow_spawns[npc.index] && i_RaidGrantExtra[npc.index] != RAIDITEM_INDEX_WIN_COND)
		Spawning_Logic(npc);


	if(b_allow_weaver[npc.index])
	{
		Weaver_Logic(npc);
	}
	
}
static void Raid_Spwaning_Logic(Magia_Anchor npc)
{
	float GameTime = GetGameTime();
	if(fl_ruina_battery_timer[npc.index] > GameTime)
		return;

	int npc_current_count;
	for(int entitycount_again_2; entitycount_again_2<i_MaxcountNpcTotal; entitycount_again_2++) //Check for npcs
	{
		int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount_again_2]);
		if(IsValidEntity(entity) && GetTeam(npc.index) == GetTeam(entity))
		{
			npc_current_count += 1;
		}
	}

	if(npc_current_count > RoundToFloor(LimitNpcs*0.4))
		return;

	float Time = 4.0;
	fl_ruina_battery_timer[npc.index] = GameTime + Time;


	static char npc_names[][] = {
		"npc_ruina_magianius",
		"npc_ruina_loonarionus",
		"npc_ruina_heliarionus",
		"npc_ruina_euranionis",
		"npc_ruina_draconia",
		"npc_ruina_malianius",
		"npc_ruina_lazurus",
		"npc_ruina_aetherianus",
		"npc_ruina_rulianius",
		"npc_ruina_astrianious",
		"npc_ruina_dronianis"
	};
	static int npc_health[] = {
		50000,	//"npc_ruina_magianius",
		75000,	//"npc_ruina_loonarionus"
		100000,	//"npc_ruina_heliarionus"
		75000,	//"npc_ruina_euranionis",
		150000,	//"npc_ruina_draconia",
		75000,	//"npc_ruina_malianius",
		100000,	//"npc_ruina_lazurus",
		75000,	//"npc_ruina_aetherianus"
		150000,	//"npc_ruina_rulianius",
		75000,	//"npc_ruina_astrianious"
		150000	//"npc_ruina_dronianis"
	};

	//Temporarily commented out because it throws a compiler error. Tell Deivid before making a PR for The Bone Zone.
	//Spawn_Anchor_NPC(npc.index, npc_names[i_current_cycle[npc.index]], npc_health[i_current_cycle[npc.index]], 1, true);

	i_current_cycle[npc.index] = GetRandomInt(0, sizeof(npc_names)-1);

	
}
static void Spawning_Logic(Magia_Anchor npc)
{
	float GameTime = GetGameTime();
	if(fl_ruina_battery_timer[npc.index] > GameTime)
		return;

	int npc_current_count;
	for(int entitycount_again_2; entitycount_again_2<i_MaxcountNpcTotal; entitycount_again_2++) //Check for npcs
	{
		int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount_again_2]);
		if(IsValidEntity(entity) && GetTeam(npc.index) == GetTeam(entity))
		{
			npc_current_count += 1;
		}
	}

	int limit = MaxEnemiesAllowedSpawnNext(0);

	switch(i_special_tower_logic[npc.index])
	{
		case 1: limit /=2;
	}

	if(npc_current_count > limit)
		return;

	int wave = i_wave[npc.index];
	float Ratio =(1.0-(wave/60.0));
	if(Ratio < -0.5)
		Ratio=-0.5;
	float Time = 1.0 + Ratio;
	
	float ratio = float(wave)/60.0;
	int health = RoundToFloor(13500.0*ratio);
	if(wave >=35)
		health = RoundToFloor(health * 2.0);
	if(wave >=60)
		health = RoundToFloor(health * 1.5);

	switch(i_special_tower_logic[npc.index])
	{
		case 1:
		{
			health = RoundToCeil(health*2.0);
		}
		default:
		{
			float PlayerMulti = 2.0 - (f_PlayerScalingBuilding/14.0);
			if(PlayerMulti < 0.8)
				PlayerMulti = 0.8;
			
			if(PlayerMulti > 2.0)
				PlayerMulti = 2.0;

			Time *= PlayerMulti;
		}
	}

	fl_ruina_battery_timer[npc.index] = GameTime + Time;
	//whats a "switch" statement??
	if(wave<=15)	
	{
		Spawn_Anchor_NPC(npc.index, "npc_ruina_drone", health, 1, true);
	}
	else if(wave <=30)	
	{
		Spawn_Anchor_NPC(npc.index, "npc_ruina_dronian", health, 2, true);
	}
	else if(wave <= 45)	
	{
		Spawn_Anchor_NPC(npc.index, "npc_ruina_dronis", health, 2, true);
	}
	else if(wave <=60)
	{
		Spawn_Anchor_NPC(npc.index, "npc_ruina_dronianis", health, 3, true);
	}
	else	//freeplay
	{
		Spawn_Anchor_NPC(npc.index, "npc_ruina_dronianis", health, 3, true);
	}
}
static void Spawn_Anchor_NPC(int iNPC, char[] plugin_name, int health = 0, int count, bool self = false)
{
	Magia_Anchor npc = view_as<Magia_Anchor>(iNPC);

	if(self)
	{
		float AproxRandomSpaceToWalkTo[3];
		WorldSpaceCenter(iNPC, AproxRandomSpaceToWalkTo);
		for(int i=0 ; i < count ; i ++)
		{
			int spawn_index = NPC_CreateByName(plugin_name, -1, AproxRandomSpaceToWalkTo, {0.0,0.0,0.0}, GetTeam(iNPC));
			if(spawn_index > MaxClients)
			{
				npc.PlayMeleeMissSound();
				npc.PlayMeleeMissSound();
				if(!health)
				{
					health = GetEntProp(spawn_index, Prop_Data, "m_iMaxHealth");
				}
				SetEntProp(spawn_index, Prop_Data, "m_iHealth", health);
				SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", health);
				NpcAddedToZombiesLeftCurrently(spawn_index, true);

				float WorldSpaceVec[3]; WorldSpaceCenter(spawn_index, WorldSpaceVec);
				ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);

				switch(i_special_tower_logic[npc.index])
				{
					case 1:
					{
						fl_Extra_Damage[spawn_index] *= 3.5;
					}
				}
			}	
		}
		return;
	}
	if(GetTeam(iNPC) == TFTeam_Red)
	{
		count /= 2;
		if(count < 1)
		{
			count = 1;
		}
		for(int Spawns; Spawns <= count; Spawns++)
		{
			float pos[3]; GetEntPropVector(iNPC, Prop_Data, "m_vecAbsOrigin", pos);
			float ang[3]; GetEntPropVector(iNPC, Prop_Data, "m_angRotation", ang);
			
			
			int summon = NPC_CreateByName(plugin_name, -1, pos, ang, GetTeam(iNPC));
			if(summon > MaxClients)
			{
				fl_Extra_Damage[summon] = 10.0;
				if(!health)
				{
					health = GetEntProp(summon, Prop_Data, "m_iMaxHealth");
				}
				SetEntProp(summon, Prop_Data, "m_iHealth", health / 4);
				SetEntProp(summon, Prop_Data, "m_iMaxHealth", health / 4);
			}
		}
		return;
	}
		
	Enemy enemy;
	enemy.Index = NPC_GetByPlugin(plugin_name);
	if(health != 0)
	{
		enemy.Health = health;
	}
	enemy.Is_Outlined = false;
	enemy.Is_Immune_To_Nuke = false;
	//do not bother outlining.
	enemy.ExtraMeleeRes = 1.0;
	enemy.ExtraRangedRes = 1.0;
	if(i_RaidGrantExtra[npc.index] == RAIDITEM_INDEX_WIN_COND)
	{
		enemy.ExtraSpeed = 1.7;
		enemy.ExtraDamage = 1.2;
	}
	else
	{
		enemy.ExtraSpeed = 1.0;
		enemy.ExtraDamage = 1.0;
	}
	enemy.ExtraSize = 1.0;		
	enemy.Team = GetTeam(iNPC);
	if(!Waves_InFreeplay())
	{
		for(int i; i<count; i++)
		{
			Waves_AddNextEnemy(enemy);
		}
	}
	else
	{
		int postWaves = CurrentRound - Waves_GetMaxRound();
		Freeplay_AddEnemy(postWaves, enemy, count);
		if(count > 0)
		{
			for(int a; a < count; a++)
			{
				Waves_AddNextEnemy(enemy);
			}
		}
	}
	Zombies_Currently_Still_Ongoing += count;	// FIXME
}
static Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	Magia_Anchor npc = view_as<Magia_Anchor>(victim);

	Ruina_NPC_OnTakeDamage_Override(npc.index, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);

	//if(fl_ruina_battery[npc.index] <=200.0)
		//Ruina_Add_Battery(npc.index, 1.0);	//anchor gets charge every hit. :)
	
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
	makeexplosion(-1, pos, 0, 0);

	b_is_magia_tower[npc.index]=false;

	if(EntRefToEntIndex(RaidBossActive)==npc.index)
		RaidBossActive = INVALID_ENT_REFERENCE;

	for(int i; i < ZR_MAX_SPAWNERS; i++)
	{
		if(i_ObjectsSpawners[i] == entity)
		{
			i_ObjectsSpawners[i] = 0;
			break;
		}
	}

	Ruina_NPCDeath_Override(entity);
		
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
}

static int i_find_weaver(Magia_Anchor npc)
{
	for(int targ; targ<i_MaxcountNpcTotal; targ++)
	{
		int baseboss_index = EntRefToEntIndexFast(i_ObjectsNpcsTotal[targ]);
		if (IsValidEntity(baseboss_index) && !b_NpcHasDied[baseboss_index] && GetTeam(npc.index) == GetTeam(baseboss_index))
		{
			char npc_classname[60];
			NPC_GetPluginById(i_NpcInternalId[baseboss_index], npc_classname, sizeof(npc_classname));
			if(StrEqual(npc_classname, "npc_ruina_stellar_weaver"))
			{
				Storm_Weaver worm = view_as<Storm_Weaver>(baseboss_index);
				if(EntRefToEntIndex(worm.m_iState) == npc.index)
					return baseboss_index;
			}
		}
	}
	return -1;
}

static void Weaver_Logic(Magia_Anchor npc)
{
	if(EntRefToEntIndex(RaidBossActive)==npc.index)
	{
		RaidModeScaling = fl_weaver_charge[npc.index];
	}

	int test = i_find_weaver(npc);
	if(test!=-1 && !IsValidEntity(EntRefToEntIndex(i_weaver_index[npc.index])))
		i_weaver_index[npc.index] = test;

	fl_weaver_charge[npc.index]+=0.002;

	if(!IsValidEntity(i_weaver_index[npc.index]) && i_weaver_index[npc.index] != INVALID_ENT_REFERENCE)
		i_weaver_index[npc.index] = INVALID_ENT_REFERENCE;

	if(fl_weaver_charge[npc.index]>=1.0)
	{
		if(i_weaver_index[npc.index] == INVALID_ENT_REFERENCE)
		{
			i_weaver_index[npc.index] = EntIndexToEntRef(i_summon_weaver(npc));
		}
		else
		{
			fl_weaver_charge[npc.index] = 0.0;
		}
	}
}
int i_GetMagiaAnchor(CClotBody npc)
{
	for(int targ; targ<i_MaxcountNpcTotal; targ++)
	{
		int baseboss_index = EntRefToEntIndexFast(i_ObjectsNpcsTotal[targ]);
		if (IsValidEntity(baseboss_index) && !b_NpcHasDied[baseboss_index] && GetTeam(npc.index) == GetTeam(baseboss_index))
		{
			if(b_is_magia_tower[baseboss_index])
				return baseboss_index;
		}
	}
	return -1;
}
static int i_summon_weaver(Magia_Anchor npc)
{
	float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
	float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
	int maxhealth;

	maxhealth = GetEntProp(npc.index, Prop_Data, "m_iHealth");

	if(EntRefToEntIndex(RaidBossActive)==npc.index)
		RaidBossActive = INVALID_ENT_REFERENCE;
	
	maxhealth = RoundToFloor(maxhealth*1.5);
	float Npc_Loc[3]; GetAbsOrigin(npc.index, Npc_Loc);
	int spawn_index = NPC_CreateByName("npc_ruina_stellar_weaver", npc.index, Npc_Loc, ang, GetTeam(npc.index), "anchor");
	if(spawn_index > MaxClients)
	{
		NpcStats_CopyStats(npc.index, spawn_index);
		if(GetTeam(npc.index) != TFTeam_Red)
		{
			NpcAddedToZombiesLeftCurrently(spawn_index, true);
		}
		Storm_Weaver worm = view_as<Storm_Weaver>(spawn_index);
		worm.m_iState = EntIndexToEntRef(npc.index);
		SetEntProp(spawn_index, Prop_Data, "m_iHealth", maxhealth);
		SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", maxhealth);
	}
	return spawn_index;
}

static bool Charging(Magia_Anchor npc)
{
	if(fl_ruina_battery[npc.index]<=255)	//charging phase
	{
	
		Ruina_Add_Battery(npc.index, 0.5);	//the anchor has the ability to build itself, but it stacks with the builders
		
		SetEntityRenderMode(npc.index, RENDER_NONE);
		int alpha = RoundToFloor(fl_ruina_battery[npc.index]);
		SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
		if(alpha > 255)
		{
			SetEntityRenderMode(npc.m_iWearable1, RENDER_NORMAL);
			alpha = 255;
		}
		//PrintToChatAll("Alpha: %i", alpha);
		SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, alpha);
		SetEntityRenderColor(npc.index, 255, 255, 255, 1);

		return false;
		
	}

	if(fl_ruina_battery[npc.index]<300 && fl_ruina_battery[npc.index]>=254) 
	{
		if(GetTeam(npc.index) != TFTeam_Red)
		{
			if(!VIPBuilding_Active())
			{
				for(int i; i < ZR_MAX_SPAWNERS; i++)
				{
					if(!i_ObjectsSpawners[i] || !IsValidEntity(i_ObjectsSpawners[i]))
					{
						Spawns_AddToArray(npc.index, true);
						i_ObjectsSpawners[i] = EntIndexToEntRef(npc.index);
						break;
					}
				}
			}
		}
		
		SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 255);
		SetEntityRenderMode(npc.m_iWearable1, RENDER_NORMAL);
		fl_ruina_battery[npc.index]=333.0;
		SetEntityRenderMode(npc.index, RENDER_NONE);
		SetEntityRenderColor(npc.index, 255, 255, 255, 1);
	}


	return true;
}