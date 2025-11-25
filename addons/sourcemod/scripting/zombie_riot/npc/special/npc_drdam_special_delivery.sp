#pragma semicolon 1
#pragma newdecls required

/*
static const char g_DeathSounds[][] = {
	"ui/killsound_squasher.wav",
};
*/
static const char g_HurtSounds[][] = {
	"physics/metal/metal_box_impact_bullet1.wav",
};

static const char g_LoudHornSound[][] = {
	"mvm/mvm_tank_horn.wav",
};
static const char g_DeployDams[][] = {
	"mvm/mvm_tank_deploy.wav",
};
static const char g_DeployedDams[][] = {
	"mvm/mvm_tank_explode.wav",
};
#define TANK_SOUND_LOOP "mvm/mvm_tank_loop.wav"
#define TANKMODEL_DRDAM "models/bots/tw2/boss_bot/boss_tank.mdl"
void DrDamSpecialDelivery_OnMapStart_NPC()
{
//	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_DeployDams));	   i++) { PrecacheSound(g_DeployDams[i]);	   }
	for (int i = 0; i < (sizeof(g_LoudHornSound));	   i++) { PrecacheSound(g_LoudHornSound[i]);	   }
	for (int i = 0; i < (sizeof(g_DeployedDams));	   i++) { PrecacheSound(g_DeployedDams[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));	   i++) { PrecacheSound(g_HurtSounds[i]);	   }
	PrecacheSound(TANK_SOUND_LOOP);
	PrecacheModel(TANKMODEL_DRDAM);
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Dr Dam's Special Delivery");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_drdam_special_delivery");
	strcopy(data.Icon, sizeof(data.Icon), "tank");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Special;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
}

static void ClotPrecache()
{
	NPC_GetByPlugin("npc_drdam_clone");
	
}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return DrDamSpecialDelivery(vecPos, vecAng, team);
}
methodmap DrDamSpecialDelivery < CClotBody
{
	property float m_flRoamCooldown
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flDeployTheDams
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flDeployingTheDams
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property float m_flLoudMVMSound
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.15;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, 1.0, GetRandomInt(90, 105));
		
	}
	public void PlayHornSound() 
	{
		if(this.m_flLoudMVMSound > GetGameTime(this.index))
			return;
			
		this.m_flLoudMVMSound = GetGameTime(this.index) + 8.0;
		
		EmitSoundToAll(g_LoudHornSound[GetRandomInt(0, sizeof(g_LoudHornSound) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, 0.6);
		
	}
	
	public void PlayLoopSound(bool loopPlay) 
	{
		if(loopPlay)
		{
			EmitSoundToAll(TANK_SOUND_LOOP, this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, 0.6);
		}
		else
		{
			StopSound(this.index, SNDCHAN_STATIC, TANK_SOUND_LOOP);
		}
	}
	public void PlayDeployTheDams() 
	{
		EmitSoundToAll(g_DeployDams[GetRandomInt(0, sizeof(g_DeployDams) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, 0.7);
	}
	public void PlayDeployedDams() 
	{
		EmitSoundToAll(g_DeployedDams[GetRandomInt(0, sizeof(g_DeployedDams) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, 0.7, 200);
	}
	/*
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 50);
	}
	*/

	
	public DrDamSpecialDelivery(float vecPos[3], float vecAng[3], int ally)
	{
		//ally = TFTeam_Stalkers;
		DrDamSpecialDelivery npc = view_as<DrDamSpecialDelivery>(CClotBody(vecPos, vecAng, TANKMODEL_DRDAM, "0.35", "500000000", ally));
		
		i_NpcIsABuilding[npc.index] = true;
		npc.m_bisWalking = false;

		i_NpcWeight[npc.index] = 2;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.AddActivityViaSequence("movement");
			

		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;	

		func_NPCDeath[npc.index] = view_as<Function>(DrDamSpecialDelivery_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(DrDamSpecialDelivery_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(DrDamSpecialDelivery_ClotThink);
		
		npc.StartPathing();
		
		npc.PlayLoopSound(true);
		ApplyStatusEffect(npc.index, npc.index, "Intangible", 999999.0);
		f_CheckIfStuckPlayerDelay[npc.index] = FAR_FUTURE;
		b_ThisEntityIgnoredBeingCarried[npc.index] = true;
		//prevent stucking or blocking at all times. 
		npc.m_flDeployTheDams = GetGameTime() + 25.0;
		npc.m_flRoamCooldown = GetGameTime() + 1.0;
		TeleportDiversioToRandLocation(npc.index);
		npc.m_bDissapearOnDeath = true;
		fl_TotalArmor[npc.index] = 0.0001;
		b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true;

		float wave = float(Waves_GetRoundScale()+1);
		wave *= 0.133333;
		npc.m_flWaveScale = wave;
		npc.m_flWaveScale *= MinibossScalingReturn();
		npc.m_iWearable2 = npc.EquipItemSeperate("models/bots/tw2/boss_bot/tank_track_l.mdl");
		npc.m_iWearable3 = npc.EquipItemSeperate("models/bots/tw2/boss_bot/tank_track_r.mdl");

		npc.m_flSpeed = 80.0;
		return npc;
	}
}

public void DrDamSpecialDelivery_ClotThink(int iNPC)
{
	DrDamSpecialDelivery npc = view_as<DrDamSpecialDelivery>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
//	ResolvePlayerCollisions_Npc(iNPC, /*damage crush*/ 1.0 * npc.m_flWaveScale);
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;

	if(npc.m_flDeployingTheDams && npc.m_flDeployingTheDams < GetGameTime(npc.index))
	{
		npc.PlayDeployedDams();
		npc.m_flDeployingTheDams = 0.0;
		int PlayerCountSpawn = CountPlayersOnRed();

		PlayerCountSpawn *= 2;

		if(PlayerCountSpawn >= 30)
			PlayerCountSpawn = 30;
		if(PlayerCountSpawn <= 3)
			PlayerCountSpawn = 3;
		//never less then 3
		float pos1[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos1);
		TE_Particle("grenade_smoke_cycle", pos1, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
		pos1[2] += 20.0;
		TE_Particle("grenade_smoke_cycle", pos1, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
		pos1[2] += 20.0;
		TE_Particle("grenade_smoke_cycle", pos1, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
		pos1[2] += 20.0;
		TE_Particle("grenade_smoke_cycle", pos1, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);

		for(int loop=1; loop<=(PlayerCountSpawn); loop++)
		{
			float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
			float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
			ang[1] = GetRandomFloat(-180.0, 180.0);
			pos[0] += GetRandomFloat(-20.0, 20.0);
			pos[1] += GetRandomFloat(-20.0, 20.0);
			int spawn_index = NPC_CreateByName("npc_drdam_clone", -1, pos, ang, GetTeam(npc.index));
			if(spawn_index > MaxClients)
			{
				ApplyStatusEffect(spawn_index, spawn_index, "UBERCHARGED", 1.0);
				NpcStats_CopyStats(npc.index, spawn_index);
				CClotBody npc1 = view_as<CClotBody>(spawn_index);
				npc1.m_flNextDelayTime = GetGameTime() + GetRandomFloat(0.2,0.4);
				//a little delay
				//SetEntProp(spawn_index, Prop_Data, "m_iHealth", maxhealth);
				//SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", maxhealth);
			}
		}
		SmiteNpcToDeath(npc.index);
		//BOOM
		return;
	}
	if(npc.m_flDeployTheDams && npc.m_flDeployTheDams < GetGameTime(npc.index))
	{
		npc.PlayDeployTheDams();
		npc.m_flDeployTheDams = 0.0;
		npc.m_flDeployingTheDams = GetGameTime(npc.index) + 7.6;
		//Deploy the DAMS
		npc.m_iWearable1 = npc.EquipItemSeperate("models/bots/boss_bot/bomb_mechanism.mdl", "deploy");
		npc.AddActivityViaSequence("deploy");
		npc.m_flSpeed = 0.0;
		npc.StopPathing();
		return;
	}
	npc.PlayHornSound();
	if(DrDamSpecialDelivery_Roam(npc, GetGameTime(npc.index)))
	{
		return;
	}
	
}

public Action DrDamSpecialDelivery_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	DrDamSpecialDelivery npc = view_as<DrDamSpecialDelivery>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}

	return Plugin_Changed;
}

public void DrDamSpecialDelivery_NPCDeath(int entity)
{
	DrDamSpecialDelivery npc = view_as<DrDamSpecialDelivery>(entity);
//	npc.PlayDeathSound();	

	npc.PlayLoopSound(false);
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

}



bool DrDamSpecialDelivery_Roam(DrDamSpecialDelivery npc, float gameTime)
{
	if(npc.m_flRoamCooldown < gameTime)
	{
		float VectorSave[3];
		VectorSave[1] = 1.0;
		TeleportDiversioToRandLocation(npc.index, true, 1500.0, 500.0, false, true, VectorSave);
		npc.m_flRoamCooldown = gameTime + 10.0;
		npc.SetGoalVector(VectorSave);
		npc.StartPathing();
	}
	return true;
}