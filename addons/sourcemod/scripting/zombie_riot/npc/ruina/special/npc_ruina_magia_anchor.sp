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

#define RUINA_TOWER_CORE_MODEL "models/props_urban/urban_skybuilding005a.mdl"
#define RUINA_TOWER_CORE_MODEL_SIZE "0.75"
#define RUINA_ANCHOR_MODEL	"models/props_combine/combine_citadel001.mdl"
#define RUINA_ANCHOR_MODEL_SIZE "0.075"

static int i_currentwave[MAXENTITIES];
//static float f_PlayerScalingBuilding;
static int Heavens_Beam;

#define MAGIA_ANCHOR_MAX_IONS 4
static float fl_Heavens_Loc[MAXENTITIES][MAGIA_ANCHOR_MAX_IONS+1][3];
static bool b_set_loc[MAXENTITIES];

void Magia_Anchor_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	PrecacheModel(RUINA_ANCHOR_MODEL);
	PrecacheModel(RUINA_TOWER_CORE_MODEL);
	Heavens_Beam = PrecacheModel(BLITZLIGHT_SPRITE);
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
	
	public Magia_Anchor(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		Magia_Anchor npc = view_as<Magia_Anchor>(CClotBody(vecPos, vecAng, RUINA_TOWER_CORE_MODEL, RUINA_TOWER_CORE_MODEL_SIZE, "10000", ally, false,true,_,_,{30.0,30.0,350.0}));
		
		i_NpcInternalId[npc.index] = RUINA_MAGIA_ANCHOR;
		i_NpcWeight[npc.index] = 999;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");

		
		npc.m_iWearable1 = npc.EquipItemSeperate("partyhat", RUINA_ANCHOR_MODEL, _, _, _, 225.0);
		SetVariantString(RUINA_ANCHOR_MODEL_SIZE);
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		/*npc.m_iWearable2 = npc.EquipItemSeperate("partyhat", "models/props_borealis/bluebarrel001.mdl");
		SetVariantString("2.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");*/

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_bDissapearOnDeath = true;

		b_set_loc[npc.index]=false;

		Ruina_Set_Sniper_Anchor_Point(npc.index, true);

		i_magia_anchors_active++;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;
		if(!ally)
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

		
		SDKHook(npc.index, SDKHook_Think, Magia_Anchor_ClotThink);

		GiveNpcOutLineLastOrBoss(npc.index, true);

		Ruina_Set_No_Retreat(npc.index);
		Ruina_Set_Recall_Anchor_Point(npc.index, true);

		Ruina_Set_Heirarchy(npc.index, 2);	//is a ranged npc. in this case its to allow buffing logic to work on it, thats it

		npc.m_iState = 0;
		npc.m_flSpeed = 0.0;
		
		npc.m_flMeleeArmor = 2.5;
		npc.m_flRangedArmor = 1.0;

		NPC_StopPathing(npc.index);

		return npc;
	}
}

public void Magia_Anchor_ClotThink(int iNPC)
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
		Heavens_Full_Charge(npc, 3, 250.0, 100.0, 12.5);

		if(npc.m_flNextMeleeAttack < GameTime)
		{
			int Target;
			Target = GetClosestTarget(npc.index);
			if(IsValidEnemy(npc.index, Target))
			{
				Warp_Non_Combat_Npcs_Near(npc.index, 2, Target);
				npc.m_flNextMeleeAttack = GameTime + 5.0;
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
	}

}

public Action Magia_Anchor_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	Magia_Anchor npc = view_as<Magia_Anchor>(victim);
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	return Plugin_Changed;
}

public void Magia_Anchor_NPCDeath(int entity)
{
	Magia_Anchor npc = view_as<Magia_Anchor>(entity);
	npc.PlayDeathSound();	
	float pos[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
	makeexplosion(-1, -1, pos, "", 0, 0);

	i_magia_anchors_active--;

	SDKUnhook(npc.index, SDKHook_Think, Magia_Anchor_ClotThink);
		
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
}

static void Heavens_Full_Charge(Magia_Anchor npc, int amt, float Radius, float aDamage, float Speed)	//rewerite this: to use a env_laser rather then TE, and also to make it prefer attacking other people then singular targets
{
	if(!b_set_loc[npc.index])
	{
		b_set_loc[npc.index]=true;
		for(int ion=0 ; ion< MAGIA_ANCHOR_MAX_IONS ; ion++)
		{
			float loc[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", loc);
			loc[0] += GetRandomFloat(350.0, -350.0);
			loc[1] += GetRandomFloat(350.0, -350.0);
			fl_Heavens_Loc[npc.index][ion] = loc;
		}
	}
	for(int i=0 ; i< amt ; i++)
	{
		float loc[3]; loc = fl_Heavens_Loc[npc.index][i];
		float Dist = -1.0;
		float Target_Loc[3]; Target_Loc = loc;
		for(int client=0 ; client <=MAXTF2PLAYERS ; client++)
		{
			if(IsValidClient(client) && IsClientInGame(client) && GetClientTeam(client) != 3 && IsEntityAlive(client) && TeutonType[client] == TEUTON_NONE && dieingstate[client] == 0)
			{
				float client_loc[3]; GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", client_loc);
				float distance = GetVectorDistance(client_loc, loc, true);
				{
					if(distance<Dist || Dist==-1)
					{
						Target_Loc = client_loc;
					}
				}
	
			}
		}
		
		float Direction[3], vecAngles[3];
		MakeVectorFromPoints(loc, Target_Loc, vecAngles);
		GetVectorAngles(vecAngles, vecAngles);
						
		GetAngleVectors(vecAngles, Direction, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(Direction, Speed);
		AddVectors(loc, Direction, loc);
		
		Ruina_Proper_To_Groud_Clip({24.0,24.0,24.0}, 300.0, loc);
		
		for(int client=0 ; client <=MAXTF2PLAYERS ; client++)
		{
			if(IsValidClient(client) && IsClientInGame(client) && GetClientTeam(client) != 3 && IsEntityAlive(client) && TeutonType[client] == TEUTON_NONE && dieingstate[client] == 0)
			{
				float client_loc[3]; GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", client_loc);
				float distance = GetVectorDistance(client_loc, loc, true);
				{
					if(distance< (Radius * Radius))
					{
						float fake_damage = aDamage*(1.0 - (distance / (Radius * Radius)));	//reduce damage if the target just grazed it.
						if(fake_damage<aDamage*0.25)
							fake_damage=aDamage*0.25;
						
						SDKHooks_TakeDamage(client, npc.index, npc.index, fake_damage * 0.85, DMG_CLUB, _, _, loc);
						Client_Shake(client, 0, 5.0, 15.0, 0.1);
					}
				}
	
			}
		}
		
		fl_Heavens_Loc[npc.index][i] = loc;
		
		int color[4];
		color[0] = 255;
		color[1] = 50;
		color[2] = 50;
		color[3] = 75;
		Heavens_SpawnBeam(loc, color, 7.5);
	}
}
static void Heavens_SpawnBeam(float beamLoc[3], int color[4], float size)
{

	float skyLoc[3];
	skyLoc[0] = beamLoc[0];
	skyLoc[1] = beamLoc[1];
	skyLoc[2] = 9999.0;
		
	TE_SetupBeamPoints(skyLoc, beamLoc, Heavens_Beam, Heavens_Beam, 0, 1, 0.1, size, size, 1, 0.5, color, 1);
	TE_SendToAll();
}