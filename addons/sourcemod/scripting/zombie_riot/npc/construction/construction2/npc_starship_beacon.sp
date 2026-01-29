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
static const char g_MeleeMissSounds[][] = {
	"ui/hitsound_vortex1.wav",
	"ui/hitsound_vortex2.wav",
	"ui/hitsound_vortex3.wav",
	"ui/hitsound_vortex4.wav",
	"ui/hitsound_vortex5.wav"
};


#define BEACON_TOWER_CORE_MODEL "models/props_urban/urban_skybuilding005a.mdl"
#define BEACON_TOWER_CORE_MODEL_SIZE "0.75"
static float f_PlayerScalingBuilding;
void Starship_Beacon_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Starship Beacon");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_starship_beacon");
	data.Category 	= Type_Outlaws;
	data.Func 		= ClotSummon;
	data.Precache 	= ClotPrecache;
	strcopy(data.Icon, sizeof(data.Icon), "teleporter"); 						//leaderboard_class_(insert the name)
	data.IconCustom = false;												//download needed?
	data.Flags = MVM_CLASS_FLAG_ALWAYSCRIT;						//example: MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;, forces these flags.	
	NPC_Add(data);
}
static void ClotPrecache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheModel(BEACON_TOWER_CORE_MODEL);
}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return Starship_Beacon(vecPos, vecAng, team, data);
}
methodmap Starship_Beacon < CClotBody
{
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;	
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
	}
	public void PlayDeathSound() {
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
	}
	public Starship_Beacon(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Starship_Beacon npc = view_as<Starship_Beacon>(CClotBody(vecPos, vecAng, BEACON_TOWER_CORE_MODEL, BEACON_TOWER_CORE_MODEL_SIZE, MinibossHealthScaling(180.0), ally, false,true,_,_,{30.0,30.0,350.0}, .NpcTypeLogic = 1));
		
		i_NpcWeight[npc.index] = 999;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");

		SetEntityRenderMode(npc.index, RENDER_NONE);
		SetEntityRenderColor(npc.index, 255, 255, 255, 1);

		npc.m_iWearable1 = npc.EquipItemSeperate(RUINA_CUSTOM_MODELS_3, _, GetTeam(npc.index) == 2 ? 2 : 3, 0.5, -15.0);
		/*
			const char[] model,
			const char[] anim = "",
			int skin = 0,
			float model_size = 1.0,
			float offset = 0.0,
			bool DontParent = false)
		*/

		f_PlayerScalingBuilding = ZRStocks_PlayerScalingDynamic();


		if(StrContains(data, "style1") != -1)
		{
			SetVariantInt(RUINA_MAGIA_TOWER_1);
			AcceptEntityInput(npc.m_iWearable1, "SetBodyGroup");
		}
		else if(StrContains(data, "style2") != -1)
		{
			SetVariantInt(RUINA_MAGIA_TOWER_2);
			AcceptEntityInput(npc.m_iWearable1, "SetBodyGroup");
		}
		else if(StrContains(data, "style3") != -1)
		{
			SetVariantInt(RUINA_MAGIA_TOWER_3);
			AcceptEntityInput(npc.m_iWearable1, "SetBodyGroup");
		}
		else if(StrContains(data, "style4") != -1)
		{
			SetVariantInt(RUINA_MAGIA_TOWER_4);						//tier 4 gregification beacon
			AcceptEntityInput(npc.m_iWearable1, "SetBodyGroup");
		}
		else
		{
			SetVariantInt(RUINA_TWIRL_CREST_4);				
			AcceptEntityInput(npc.m_iWearable1, "SetBodyGroup");
		}

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_bDissapearOnDeath = true;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;

		i_NpcIsABuilding[npc.index] = true;
	
		//npc.m_flWaveScale = wave;

		b_ThisNpcIsImmuneToNuke[npc.index] = true;

		func_NPCDeath[npc.index] 		= NPC_Death;
		func_NPCOnTakeDamage[npc.index] = OnTakeDamage;
		func_NPCThink[npc.index] 		= ClotThink;

		GiveNpcOutLineLastOrBoss(npc.index, true);

		npc.m_iState = 0;
		npc.m_flSpeed = 0.0;
		
		npc.m_flMeleeArmor = 1.0;
		npc.m_flRangedArmor = 1.0;
		npc.m_flAttackHappens = 0.0;

		npc.m_flMeleeArmor = 2.5;
		f_ExtraOffsetNpcHudAbove[npc.index] = 115.0;

		if(!VIPBuilding_Active() && GetTeam(npc.index) != TFTeam_Red)
		{
			for(int i; i < ZR_MAX_SPAWNERS; i++)
			{
				if(!i_ObjectsSpawners[i] || !IsValidEntity(i_ObjectsSpawners[i]))
				{
					Spawns_AddToArray(EntIndexToEntRef(npc.index), true);
					i_ObjectsSpawners[i] = EntIndexToEntRef(npc.index);
					break;
				}
			}
		}

		return npc;
	}
}
static void ClotThink(int iNPC)
{
	Starship_Beacon npc = view_as<Starship_Beacon>(iNPC);

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
		return;

	npc.m_flNextThinkTime = GameTime + 0.1;

	NotifyOfExistance(npc);
	
}

static void NotifyOfExistance(Starship_Beacon npc)
{
	if(!npc.m_flAttackHappens)
	{
		npc.m_flAttackHappens = FAR_FUTURE;
		float VecSelfNpcabs[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", VecSelfNpcabs);
		VecSelfNpcabs[2] += 100.0;
		if(SpawnedOneAlready > GetGameTime())
		{
			Event event = CreateEvent("show_annotation");
			if(event)
			{
				event.SetFloat("worldPosX", VecSelfNpcabs[0]);
				event.SetFloat("worldPosY", VecSelfNpcabs[1]);
				event.SetFloat("worldPosZ", VecSelfNpcabs[2]);
				event.SetFloat("lifetime", 7.0);
				event.SetString("text", "Multiple StarShip Beacons!");
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
				event.SetString("text", "StarShip Beacon");
				event.SetString("play_sound", "vo/null.mp3");
				IdRef++;
				event.SetInt("id", IdRef); //What to enter inside? Need a way to identify annotations by entindex!
				event.Fire();
			}
			SpawnedOneAlready = GetGameTime() + 60.0;
		}
	}
}

static Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	Starship_Beacon npc = view_as<Starship_Beacon>(victim);

	if(npc.m_iState != -1)
		ShareDamageWithShip(npc, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition);
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	return Plugin_Changed;
}
static void ShareDamageWithShip(Starship_Beacon npc, int attacker, int inflictor, float damage, int damagetype, int weapon, float damageForce[3], float damagePosition[3])
{
	int Ship = EntRefToEntIndex(npc.m_iState);

	if(!IsValidEntity(Ship))
	{
		npc.m_iState = -1;
		return;
	}

	if(i_HexCustomDamageTypes[npc.index] & ZR_DAMAGE_NPC_REFLECT)	//do not.
		return;

	SDKHooks_TakeDamage(Ship, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, false, (ZR_DAMAGE_NOAPPLYBUFFS_OR_DEBUFFS|ZR_DAMAGE_NPC_REFLECT));
}

static void NPC_Death(int entity)
{
	Starship_Beacon npc = view_as<Starship_Beacon>(entity);
	npc.PlayDeathSound();	
	float pos[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
	makeexplosion(-1, pos, 0, 0);

	for(int i; i < ZR_MAX_SPAWNERS; i++)
	{
		if(i_ObjectsSpawners[i] == entity)
		{
			i_ObjectsSpawners[i] = 0;
			break;
		}
	}

	int Ship = EntRefToEntIndex(npc.m_iState);
	if(IsValidEntity(Ship))
	{
		RegaliaClass ship = view_as<RegaliaClass>(Ship);
		ship.m_iBeaconsExist--;
	}
		
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
}