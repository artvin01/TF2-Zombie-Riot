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
static bool b_allow_weaver[MAXENTITIES];
static float fl_weaver_charge[MAXENTITIES];
static int i_weaver_index[MAXENTITIES];

#define RUINA_TOWER_CORE_MODEL "models/props_urban/urban_skybuilding005a.mdl"
#define RUINA_TOWER_CORE_MODEL_SIZE "0.75"

void Magia_Anchor_OnMapStart_NPC()
{
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
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return Magia_Anchor(client, vecPos, vecAng, ally, data);
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
	
	public Magia_Anchor(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Magia_Anchor npc = view_as<Magia_Anchor>(CClotBody(vecPos, vecAng, RUINA_TOWER_CORE_MODEL, RUINA_TOWER_CORE_MODEL_SIZE, "10000", ally, false,true,_,_,{30.0,30.0,350.0}));
		
		i_NpcWeight[npc.index] = 999;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");

		b_is_magia_tower[npc.index]=true;

		npc.m_iWearable1 = npc.EquipItemSeperate("partyhat", RUINA_CUSTOM_MODELS_3, _, _, _, 15.0);
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 255, 255, 255, 1);

		int wave = ZR_GetWaveCount()+1;

		if(StrContains(data, "force15") != -1)
			wave = 15;
		if(StrContains(data, "force30") != -1)
			wave = 30;
		if(StrContains(data, "force45") != -1)
			wave = 45;
		if(StrContains(data, "force60") != -1)
			wave = 60;

		fl_weaver_charge[npc.index] = 0.0;
		i_weaver_index[npc.index] = INVALID_ENT_REFERENCE;

		if(StrContains(data, "noweaver") != -1)
			b_allow_weaver[npc.index] = false;
		else
			b_allow_weaver[npc.index] = true;
		
		if(StrContains(data, "raid") != -1)
			i_RaidGrantExtra[entity] = RAIDITEM_INDEX_WIN_COND;
		
		//whats a "switch" statement??
		if(wave<=15)	
		{
			SetVariantInt(RUINA_MAGIA_TOWER_1);
			AcceptEntityInput(npc.m_iWearable1, "SetBodyGroup");
		}
		else if(wave <=30)	
		{
			SetVariantInt(RUINA_MAGIA_TOWER_2);
			AcceptEntityInput(npc.m_iWearable1, "SetBodyGroup");
		}
		else if(wave <= 45)	
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
			RaidBossActive = EntIndexToEntRef(npc.index);
			RaidAllowsBuildings = false;

			RaidModeScaling = 0.0;
		
		}

		fl_ruina_battery[npc.index] = 0.0;

		bool full = StrContains(data, "full") != -1;

		if(full)
		{
			fl_ruina_battery[npc.index] = 255.0;
		}

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_bDissapearOnDeath = true;

		Ruina_Set_Sniper_Anchor_Point(npc.index, true);
		
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

		//f_PlayerScalingBuilding = float(CountPlayersOnRed());

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

	Charging(npc);

	npc.m_flNextThinkTime = GameTime + 0.1;

	if(i_RaidGrantExtra[entity] == RAIDITEM_INDEX_WIN_COND)	//we are summoned by a raidboss, do custom stuff.
	{

	}

	if(b_allow_weaver[npc.index])
	{

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

	Ruina_NPCDeath_Override(entity);
		
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
}

static void Weaver_Logic(Magia_Anchor npc)
{
	if(EntRefToEntIndex(RaidBossActive)==npc.index)
	{
		RaidModeScaling = fl_weaver_charge[npc.index];
	}

	fl_weaver_charge[npc.index]+=0.005;

	if(fl_weaver_charge[npc.index]>=1.0)
	{
		if(i_weaver_index[npc.index] != INVALID_ENT_REFERENCE)
		{
			i_weaver_index[npc.index] = EntIndexToEntRef();
		}
		else
		{
			fl_weaver_charge[npc.index] = 0.0;
		}
	}
}
static int i_summon_weaver(Magia_Anchor npc)
{
	
}

static void Charging(Magia_Anchor npc)
{
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
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 255, 255, 255, 1);
		
	}
	if(fl_ruina_battery[npc.index]<300 && fl_ruina_battery[npc.index]>=254) 
	{
		SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 255);
		SetEntityRenderMode(npc.m_iWearable1, RENDER_NORMAL);
		fl_ruina_battery[npc.index]=333.0;
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 255, 255, 255, 1);
	}
}