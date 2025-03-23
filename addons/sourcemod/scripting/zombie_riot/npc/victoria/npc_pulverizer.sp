#pragma semicolon 1
#pragma newdecls required


static const char g_DeathSounds[][] = {
	")vo/pyro_negativevocalization01.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/pyro_painsharp01.mp3",
	"vo/pyro_painsharp02.mp3",
	"vo/pyro_painsharp03.mp3",
	"vo/pyro_painsharp04.mp3",
	"vo/pyro_painsharp05.mp3",
};
static const char g_IdleAlertedSounds[][] = {
	"vo/taunts/pyro_taunts01.mp3",
	"vo/taunts/pyro_taunts02.mp3",
	"vo/taunts/pyro_taunts03.mp3",
};


void VictorianPulverizer_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	PrecacheSound("weapons/flame_thrower_dg_loop.wav");
	PrecacheSound("weapons/flame_thrower_pilot.wav");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Pulverizer");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_pulverizer");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_pulverizer");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Victoria;
	data.Func = ClotSummon;
	int id = NPC_Add(data);
	Rogue_Paradox_AddWinterNPC(id);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return VictorianPulverizer(client, vecPos, vecAng, ally);
}

methodmap VictorianPulverizer < CClotBody
{

	property int i_GunMode
	{
		public get()							{ return i_TimesSummoned[this.index]; }
		public set(int TempValueForProperty) 	{ i_TimesSummoned[this.index] = TempValueForProperty; }
	}
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
	}
	property float m_flPulveriserAttackDelay
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMinigunSound(bool Shooting) 
	{
		if(Shooting)
		{
			if(this.i_GunMode != 0)
			{
				StopSound(this.index, SNDCHAN_STATIC, "weapons/flame_thrower_pilot.wav");
				EmitSoundToAll("weapons/flame_thrower_dg_loop.wav", this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, 0.70, 80);
			}
			this.i_GunMode = 0;
		}
		else
		{
			if(this.i_GunMode != 1)
			{
				StopSound(this.index, SNDCHAN_STATIC, "weapons/flame_thrower_dg_loop.wav");
				EmitSoundToAll("weapons/flame_thrower_pilot.wav", this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, 0.70,  80);
			}
			this.i_GunMode = 1;
		}
	}
	
	public VictorianPulverizer(int client, float vecPos[3], float vecAng[3], int ally)
	{
		VictorianPulverizer npc = view_as<VictorianPulverizer>(CClotBody(vecPos, vecAng, "models/player/pyro.mdl", "1.0", "30000", ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_PRIMARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(5);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(VictorianPulverizer_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(VictorianPulverizer_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(VictorianPulverizer_ClotThink);
		
		
		//IDLE
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		npc.m_flSpeed = 230.0;
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_drg_phlogistinator/c_drg_phlogistinator.mdl");
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/pyro/hw2013_rugged_respirator/hw2013_rugged_respirator.mdl");
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/pyro/sum24_fire_marshal/sum24_fire_marshal.mdl");
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/pyro/sum24_invisible_flame_style2/sum24_invisible_flame_style2.mdl");
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/pyro/sum24_scorched_stompers_style2/sum24_scorched_stompers_style2.mdl");
		
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);

		npc.m_bDissapearOnDeath = true;
		
		return npc;
	}
}

public void VictorianPulverizer_ClotThink(int iNPC)
{
	VictorianPulverizer npc = view_as<VictorianPulverizer>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
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
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3];
			PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
			NPC_SetGoalVector(npc.index, vPredictedPos);
		}
		else 
		{
			NPC_SetGoalEntity(npc.index, npc.m_iTarget);
		}
		VictorianPulverizerSelfDefense(npc); 
	}
	else
	{
		npc.PlayMinigunSound(false);
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action VictorianPulverizer_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VictorianPulverizer npc = view_as<VictorianPulverizer>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void VictorianPulverizer_NPCDeath(int entity)
{
	VictorianPulverizer npc = view_as<VictorianPulverizer>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
		
	StopSound(npc.index, SNDCHAN_STATIC, "weapons/flame_thrower_dg_loop.wav");
	StopSound(npc.index, SNDCHAN_STATIC, "weapons/flame_thrower_pilot.wav");
	StopSound(npc.index, SNDCHAN_STATIC, "weapons/flame_thrower_dg_loop.wav");
	StopSound(npc.index, SNDCHAN_STATIC, "weapons/flame_thrower_pilot.wav");
	
	int entity_death = CreateEntityByName("prop_dynamic_override");
	if(IsValidEntity(entity_death))
	{
		VictorianPulverizer prop = view_as<VictorianPulverizer>(entity_death);
		float pos[3];
		float Angles[3];
		GetEntPropVector(entity, Prop_Data, "m_angRotation", Angles);

		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
		TeleportEntity(entity_death, pos, Angles, NULL_VECTOR);

		DispatchKeyValue(entity_death, "model", "models/player/pyro.mdl");

		DispatchSpawn(entity_death);
		
		prop.m_iWearable1 = prop.EquipItem("head", "models/workshop/player/items/pyro/hw2013_rugged_respirator/hw2013_rugged_respirator.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(prop.m_iWearable1, "SetModelScale");

		prop.m_iWearable2 = prop.EquipItem("head", "models/workshop/player/items/pyro/sum24_fire_marshal/sum24_fire_marshal.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(prop.m_iWearable2, "SetModelScale");

		prop.m_iWearable3 = prop.EquipItem("head", "models/workshop/player/items/pyro/sum24_invisible_flame_style2/sum24_invisible_flame_style2.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(prop.m_iWearable3, "SetModelScale");
		
		prop.m_iWearable4 = prop.EquipItem("head", "models/workshop/player/items/pyro/sum24_scorched_stompers_style2/sum24_scorched_stompers_style2.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(prop.m_iWearable4, "SetModelScale");


		DispatchKeyValue(entity_death, "skin", "1");
		DispatchKeyValue(prop.m_iWearable1, "skin", "1");
		DispatchKeyValue(prop.m_iWearable2, "skin", "1");
		DispatchKeyValue(prop.m_iWearable3, "skin", "1");
		DispatchKeyValue(prop.m_iWearable4, "skin", "1");

		SetVariantInt(5);
		AcceptEntityInput(entity_death, "SetBodyGroup");
 
		SetEntityCollisionGroup(entity_death, 2);
		SetVariantString("dieviolent");
		AcceptEntityInput(entity_death, "SetAnimation");
		
		CreateTimer(1.0, Timer_RemoveEntity, EntIndexToEntRef(entity_death), TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(1.0, Timer_RemoveEntity, EntIndexToEntRef(prop.m_iWearable1), TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(1.0, Timer_RemoveEntity, EntIndexToEntRef(prop.m_iWearable2), TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(1.0, Timer_RemoveEntity, EntIndexToEntRef(prop.m_iWearable3), TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(1.0, Timer_RemoveEntity, EntIndexToEntRef(prop.m_iWearable4), TIMER_FLAG_NO_MAPCHANGE);
	}
	if(!NpcStats_IsEnemySilenced(npc.index))
	{
		float startPosition[3];
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", startPosition); 
		startPosition[2] += 45;

		KillFeed_SetKillIcon(npc.index, "ullapool_caber_explosion");
		b_NpcIsTeamkiller[npc.index] = true;
		Explode_Logic_Custom(25.0, -1, npc.index, -1, startPosition, 100.0, _, _, true, _, true);
		b_NpcIsTeamkiller[npc.index] = false;

		DataPack pack_boom = new DataPack();
		pack_boom.WriteFloat(startPosition[0]);
		pack_boom.WriteFloat(startPosition[1]);
		pack_boom.WriteFloat(startPosition[2]);
		pack_boom.WriteCell(1);
		RequestFrame(MakeExplosionFrameLater, pack_boom);
	}

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

void VictorianPulverizerSelfDefense(VictorianPulverizer npc)
{
	if(npc.m_flPulveriserAttackDelay > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flPulveriserAttackDelay = GetGameTime(npc.index) + 0.2;

	int target;
	target = npc.m_iTarget;
	//some Ranged units will behave differently.
	//not this one.
	float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
	bool SpinSound = true;
	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
	if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 5.0))
	{
		npc.PlayMinigunSound(true);
		SpinSound = false;
		npc.FaceTowards(vecTarget, 20000.0);
		int projectile = npc.FireParticleRocket(vecTarget, 18.0, 1000.0, 150.0, "superrare_burning2", true);
		SDKUnhook(projectile, SDKHook_StartTouch, Rocket_Particle_StartTouch);
		int particle = EntRefToEntIndex(i_rocket_particle[projectile]);
		CreateTimer(0.5, Timer_RemoveEntity, EntIndexToEntRef(projectile), TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(0.5, Timer_RemoveEntity, EntIndexToEntRef(particle), TIMER_FLAG_NO_MAPCHANGE);
		
		SDKHook(projectile, SDKHook_StartTouch, VictorianPulverizer_Rocket_Particle_StartTouch);		
	}
	if(SpinSound)
		npc.PlayMinigunSound(false);
}



public void VictorianPulverizer_Rocket_Particle_StartTouch(int entity, int target)
{
	if(target > 0 && target < MAXENTITIES)	//did we hit something???
	{
		int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		if(!IsValidEntity(owner))
		{
			owner = 0;
		}
		
		int inflictor = h_ArrowInflictorRef[entity];
		if(inflictor != -1)
			inflictor = EntRefToEntIndex(h_ArrowInflictorRef[entity]);

		if(inflictor == -1)
			inflictor = owner;
			
		float ProjectileLoc[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);
		float DamageDeal = fl_rocket_particle_dmg[entity];
		if(ShouldNpcDealBonusDamage(target))
			DamageDeal *= h_BonusDmgToSpecialArrow[entity];


		SDKHooks_TakeDamage(target, owner, inflictor, DamageDeal, DMG_BULLET|DMG_PREVENT_PHYSICS_FORCE, -1);	//acts like a kinetic rocket	
		float BurninHell = 1.0;
		if(NpcStats_VictorianCallToArms(owner))
		{
			BurninHell *= 3.0;
		}
		BurninHell *= 0.5;
		NPC_Ignite(target, owner,20.0, -1, BurninHell);

		int particle = EntRefToEntIndex(i_rocket_particle[entity]);
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
	}
	else
	{
		int particle = EntRefToEntIndex(i_rocket_particle[entity]);
		//we uhh, missed?
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
	}
	RemoveEntity(entity);
}