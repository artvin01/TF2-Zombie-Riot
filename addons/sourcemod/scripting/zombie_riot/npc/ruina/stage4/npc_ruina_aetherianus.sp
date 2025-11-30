#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/sniper_paincrticialdeath01.mp3",
	"vo/sniper_paincrticialdeath02.mp3",
	"vo/sniper_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/sniper_painsharp01.mp3",
	"vo/sniper_painsharp02.mp3",
	"vo/sniper_painsharp03.mp3",
	"vo/sniper_painsharp04.mp3",
};
static const char g_IdleSounds[][] = {
	"vo/sniper_standonthepoint01.mp3",
	"vo/sniper_standonthepoint02.mp3",
	"vo/sniper_standonthepoint03.mp3",
	"vo/sniper_standonthepoint04.mp3",
	"vo/sniper_standonthepoint05.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/sniper_battlecry01.mp3",
	"vo/sniper_battlecry02.mp3",
	"vo/sniper_battlecry03.mp3",
	"vo/sniper_battlecry04.mp3",
	"vo/sniper_battlecry05.mp3",
};
static const char g_RangedAttackSounds[][] = {
	"weapons/dragons_fury_shoot.wav",
};

static const char g_RangedReloadSound[][] = {
	"weapons/dragons_fury_pressure_build.wav",
};

static const char g_HyperArrowSound[][] = {
	"ambient_mp3/halloween/thunder_01.mp3",
	"ambient_mp3/halloween/thunder_02.mp3",
	"ambient_mp3/halloween/thunder_03.mp3",
	"ambient_mp3/halloween/thunder_04.mp3",
	"ambient_mp3/halloween/thunder_05.mp3",
	"ambient_mp3/halloween/thunder_06.mp3",
	"ambient_mp3/halloween/thunder_07.mp3",
	"ambient_mp3/halloween/thunder_08.mp3",
	"ambient_mp3/halloween/thunder_09.mp3",
	"ambient_mp3/halloween/thunder_10.mp3"
};

void Aetherianus_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Aetherianus");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_ruina_aetherianus");
	data.Category = Type_Ruina;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	strcopy(data.Icon, sizeof(data.Icon), "sniper_bow_multi"); 						//leaderboard_class_(insert the name)
	data.IconCustom = false;												//download needed?
	data.Flags = 0;						//example: MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;, forces these flags.	
	NPC_Add(data);
}
static void ClotPrecache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_RangedAttackSounds);
	PrecacheSoundArray(g_RangedReloadSound);
	PrecacheSoundArray(g_HyperArrowSound);

	PrecacheModel("models/player/sniper.mdl");
}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Aetherianus(vecPos, vecAng, team);
}

static float fl_npc_basespeed;
methodmap Aetherianus < CClotBody
{
	
	public void PlayHyperArrowSound() {
		EmitSoundToAll(g_HyperArrowSound[GetRandomInt(0, sizeof(g_HyperArrowSound) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
	}

	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
		
	}
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);	
		
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);	
		
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
			
	}
	
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, 0.5, RUINA_NPC_PITCH);
		

	}
	public void PlayRangedReloadSound() {
		EmitSoundToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
			
	}
	
	public void Set_WalkCycle()
	{
		bool Aimed = false;

		float GameTime = GetGameTime(this.index);

		if(this.m_flAttackHappens > GameTime)	//we are currently firing a hyper arrow.
			Aimed = true;

		if(this.m_flNextRangedAttack < (GameTime + 1.0))	//we are about to fire a arrow, aim.
			Aimed = true;

		if(Aimed)
		{
			if(!this.m_fbGunout)
			{
				int iActivity = this.LookupActivity("ACT_MP_DEPLOYED_ITEM2");	//OR ACT_MP_DEPLOYED_ITEM2
				if(iActivity > 0) this.StartActivity(iActivity);
				this.m_fbGunout = true;
			}
		}
		else
		{
			if(this.m_fbGunout)
			{
				int iActivity = this.LookupActivity("ACT_MP_RUN_ITEM2");
				if(iActivity > 0) this.StartActivity(iActivity);
				this.m_fbGunout = false;
			}
		}
	}
	
	public Aetherianus(float vecPos[3], float vecAng[3], int ally)
	{
		Aetherianus npc = view_as<Aetherianus>(CClotBody(vecPos, vecAng, "models/player/sniper.mdl", "1.0", "1250", ally));

		i_NpcWeight[npc.index] = 1;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_ITEM2");	//OR ACT_MP_DEPLOYED_ITEM2
		if(iActivity > 0) npc.StartActivity(iActivity);
		npc.m_fbGunout = false;

		SetVariantInt(2);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		npc.m_iChanged_WalkCycle = 1;
		
		
		/*
			//angel of death
			//dread hiding hood
			//golden garment
			//tuxxy						"models/player/items/all_class/tuxxy_%s.mdl"
			//Triggerman's tacticals	"models/workshop/player/items/sniper/short2014_sniper_cargo_pants/short2014_sniper_cargo_pants.mdl"
		
		*/
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(NPC_Death);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(ClotThink);

		fl_npc_basespeed = 230.0;
		npc.m_flSpeed = fl_npc_basespeed;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();

		static const char Items[][] = {
			"models/workshop/player/items/medic/xms2013_medic_robe/xms2013_medic_robe.mdl",
			"models/workshop/player/items/sniper/xms2013_sniper_golden_garment/xms2013_sniper_golden_garment.mdl",
			"models/workshop_partner/player/items/sniper/thief_sniper_hood/thief_sniper_hood.mdl",
			"models/player/items/all_class/tuxxy_sniper.mdl",
			"models/workshop/player/items/sniper/short2014_sniper_cargo_pants/short2014_sniper_cargo_pants.mdl",
			RUINA_CUSTOM_MODELS_3
		};

		int skin = 1;	//1=blue, 0=red
		SetVariantInt(1);	
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		npc.m_iWearable1 = npc.EquipItem("head", Items[0], _, skin);
		npc.m_iWearable2 = npc.EquipItem("head", Items[1], _, skin);
		npc.m_iWearable3 = npc.EquipItem("head", Items[2], _, skin);
		npc.m_iWearable4 = npc.EquipItem("head", Items[3], _, skin);
		npc.m_iWearable5 = npc.EquipItem("head", Items[4], _, skin);
		npc.m_iWearable6 = npc.EquipItem("head", Items[5]);

		SetVariantInt(RUINA_QUINCY_BOW_3);
		AcceptEntityInput(npc.m_iWearable6, "SetBodyGroup");	
			
		fl_ruina_battery_max[npc.index] = 500.0;
		fl_ruina_battery[npc.index] = 500.0;
		b_ruina_battery_ability_active[npc.index] = false;
		fl_ruina_battery_timer[npc.index] = 0.0;
		
		Ruina_Set_Heirarchy(npc.index, RUINA_RANGED_NPC);	//is a ranged npc

		fl_ruina_battery_timeout[npc.index] = 0.0;

		return npc;
	}
	
	
}

static void Find_Aetherians(Aetherianus npc)
{
	float radius = 250.0;

	b_NpcIsTeamkiller[npc.index] = true;
	Explode_Logic_Custom(0.0, npc.index, npc.index, -1, _, radius, _, _, true, 50, false, _, FindAllies_Logic);
	b_NpcIsTeamkiller[npc.index] = false;
	
}

static void FindAllies_Logic(int entity, int victim, float damage, int weapon)
{
	if(entity==victim)
		return;

	if(GetTeam(entity) != GetTeam(victim))
		return;

	
	char npc_classname[60];
	NPC_GetPluginById(i_NpcInternalId[victim], npc_classname, sizeof(npc_classname));

	bool valid = false;

	static const char Compare[][] = {
		"npc_ruina_aetherianus",
		"npc_ruina_aetherium",
		"npc_ruina_aetheria",
		"npc_ruina_aether"
	};

	for(int i=0 ; i < 4 ; i ++)
	{
		if(StrEqual(npc_classname, Compare[i]))
		{
			valid = true;
			break;
		}
	}
	if(!valid)
		return;

	fl_ruina_buff_amt[entity] = 0.5;
	fl_ruina_buff_time[entity] = 5.0;
	b_ruina_buff_override[entity] = true;
	Ruina_Apply_Attack_buff(entity, victim, 0.0, 0);
}



static void ClotThink(int iNPC)
{
	Aetherianus npc = view_as<Aetherianus>(iNPC);
	
	float GameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > GameTime)
	{
		return;
	}
	
	//Ruina_Add_Battery(npc.index, 5.0);
	
	npc.m_flNextDelayTime = GameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
			
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
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
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GameTime + GetRandomRetargetTime();
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;

	Ruina_Add_Battery(npc.index, 1.0);

	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		npc.Set_WalkCycle();

		int Anchor_Id=-1;
		Ruina_Independant_Long_Range_Npc_Logic(npc.index, PrimaryThreatIndex, GameTime, Anchor_Id); //handles movement

		if(fl_ruina_battery_timeout[npc.index] < GameTime)
		{
			Find_Aetherians(npc);
			fl_ruina_battery_timeout[npc.index] = GameTime + 1.0;
		}

		float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
		float Npc_Vec[3]; WorldSpaceCenter(npc.index, Npc_Vec);
		float flDistanceToTarget = GetVectorDistance(vecTarget, Npc_Vec, true);
		

		if(!IsValidEntity(Anchor_Id))
		{
			if(flDistanceToTarget < (500.0*500.0))
			{
				int Enemy_I_See;
				
				Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
				//Target close enough to hit
				if(IsValidEnemy(npc.index, Enemy_I_See)) //Check if i can even see.
				{
					if(flDistanceToTarget < (300.0*300.0))
					{
						npc.m_bAllowBackWalking=true;
						Ruina_Runaway_Logic(npc.index, PrimaryThreatIndex);
					}
					else
					{
						npc.StopPathing();
						npc.m_bAllowBackWalking=false;
						
					}
				}
				else
				{
					npc.StartPathing();
					
					npc.m_bAllowBackWalking=false;
				}
			}
			else
			{
				npc.StartPathing();
				
				npc.m_bAllowBackWalking=false;
			}
		}
		else
		{
			npc.m_bAllowBackWalking=false;
		}

		if(npc.m_bAllowBackWalking)
		{
			npc.m_flSpeed = fl_npc_basespeed*RUINA_BACKWARDS_MOVEMENT_SPEED_PENALTY;
			npc.FaceTowards(vecTarget, RUINA_FACETOWARDS_BASE_TURNSPEED);
		}	
		else
			npc.m_flSpeed = fl_npc_basespeed;
		
		Aetherianus_SelfDefense(npc, GameTime, Anchor_Id);
	}
	else
	{
		npc.StopPathing();
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

static Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Aetherianus npc = view_as<Aetherianus>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
	
	Ruina_NPC_OnTakeDamage_Override(npc.index, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);	//ruina logic happens first, then npc
		
	//Ruina_Add_Battery(npc.index, damage);	//turn damage taken into energy
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static void NPC_Death(int entity)
{
	Aetherianus npc = view_as<Aetherianus>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}

	Ruina_NPCDeath_Override(npc.index);

	int Laser_End = EntRefToEntIndex(i_laz_entity[npc.index]);

	if(IsValidEntity(Laser_End))
	{
		RemoveEntity(Laser_End);
		i_laz_entity[npc.index] = INVALID_ENT_REFERENCE;
	}

	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);
}

static void On_LaserHit(int client, int target, int damagetype, float damage)
{
	Ruina_Add_Mana_Sickness(client, target, 0.05, 3);
}

static void Func_On_Proj_Touch(int projectile, int other)
{
	int owner = GetEntPropEnt(projectile, Prop_Send, "m_hOwnerEntity");
	if(!IsValidEntity(owner))
	{
		owner = 0;
	}
	else
	{
		Aetherianus npc = view_as<Aetherianus>(owner);
		i_laz_entity[npc.index] = INVALID_ENT_REFERENCE;
	}

	if(IsValidEnemy(owner, other))
	{
		Ruina_Add_Mana_Sickness(owner, other, 0.5, 100);

		float Dmg = fl_ruina_Projectile_dmg[projectile];
		if(ShouldNpcDealBonusDamage(other))
			Dmg = fl_ruina_Projectile_bonus_dmg[projectile];

		float ProjectileLoc[3];
		GetEntPropVector(projectile, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);
		
		SDKHooks_TakeDamage(other, owner, owner, Dmg, DMG_PLASMA, -1, _, ProjectileLoc);
	}

	Ruina_Remove_Projectile(projectile);
}

static void Aetherianus_SelfDefense(Aetherianus npc, float gameTime, int Anchor_Id)	//ty artvin
{
	int GetClosestEnemyToAttack;
	//Ranged units will behave differently.
	//Get the closest visible target via distance checks, not via pathing check.
	GetClosestEnemyToAttack = GetClosestTarget(npc.index,_,_,_,_,_,_,true,_,_,true);	//works with masters, slaves not so much. seems to work with independant npc's too
	if(!IsValidEnemy(npc.index,GetClosestEnemyToAttack))	//no target, what to do while idle
	{
		return;
	}
	float vecTarget[3]; WorldSpaceCenter(GetClosestEnemyToAttack, vecTarget);
	float Npc_Vec[3]; WorldSpaceCenter(npc.index, Npc_Vec);
	float flDistanceToTarget = GetVectorDistance(vecTarget, Npc_Vec, true);

	if(npc.m_flAttackHappens > gameTime)
	{
		npc.m_flSpeed = 0.0;
		int Laser_End = EntRefToEntIndex(i_laz_entity[npc.index]);

		if(!IsValidEntity(Laser_End))
		{
			npc.m_flAttackHappens = 0.0;
			i_laz_entity[npc.index] = INVALID_ENT_REFERENCE;

			return;
		}

		float Proj_Vec[3];
		GetEntPropVector(Laser_End, Prop_Data, "m_vecAbsOrigin", Proj_Vec);

		npc.FaceTowards(Proj_Vec, 200000.0);
			
		Ruina_Laser_Logic Laser;

		Laser.client = npc.index;
		Laser.Start_Point = Npc_Vec;
		Laser.End_Point = Proj_Vec;

		float dmg = 40.0;
		float radius = 15.0;

		Laser.Radius = radius;
		Laser.Damage = dmg;
		Laser.Bonus_Damage = dmg*6.0;
		Laser.damagetype = DMG_PLASMA;

		Laser.Deal_Damage(On_LaserHit);
	}

	if(flDistanceToTarget < (1500.0*1500.0))
	{	
		if(npc.m_flNextRangedAttack < gameTime)
		{
			if(fl_ruina_battery[npc.index]>fl_ruina_battery_max[npc.index])
			{
				int Laser_End = EntRefToEntIndex(i_laz_entity[npc.index]);

				if(IsValidEntity(Laser_End))
					return;

				Fire_Hyper_Arrow(npc, Npc_Vec, GetClosestEnemyToAttack, vecTarget);	
			}
			else
			{
				fl_ruina_in_combat_timer[npc.index]=gameTime+5.0;
				npc.AddGesture("ACT_MP_ATTACK_STAND_ITEM2", true);
				npc.PlayRangedSound();
				float projectile_speed = 2000.0;
				WorldSpaceCenter(GetClosestEnemyToAttack, vecTarget);
				float DamageDone = 80.0;
				npc.FireParticleRocket(vecTarget, DamageDone, projectile_speed, 0.0, "spell_fireball_small_blue", false, true, false,_,_,_,10.0);
				npc.FaceTowards(vecTarget, 20000.0);
				npc.m_flNextRangedAttack = gameTime + 6.5;
			}
			
		}
	}
	else
	{
		if(IsValidEntity(Anchor_Id))
		{
			CClotBody npc2 = view_as<CClotBody>(Anchor_Id);
			int	target = npc2.m_iTarget;

			if(IsValidEnemy(npc.index,target))
			{
				fl_ruina_in_combat_timer[npc.index]=gameTime+5.0;
				GetClosestEnemyToAttack = target;
				WorldSpaceCenter(GetClosestEnemyToAttack, vecTarget);

				flDistanceToTarget = GetVectorDistance(vecTarget, Npc_Vec, true);

				if(gameTime > npc.m_flNextRangedAttack)
				{
					if(fl_ruina_battery[npc.index]>fl_ruina_battery_max[npc.index])
					{
						int Laser_End = EntRefToEntIndex(i_laz_entity[npc.index]);

						if(IsValidEntity(Laser_End))
							return;

						Fire_Hyper_Arrow(npc, Npc_Vec, target, vecTarget);	
					}
					else
					{
						npc.AddGesture("ACT_MP_ATTACK_STAND_ITEM2", true);
						npc.PlayRangedSound();
						float projectile_speed = 2000.0;
						WorldSpaceCenter(GetClosestEnemyToAttack, vecTarget);
						float DamageDone = 80.0;
						npc.FireParticleRocket(vecTarget, DamageDone, projectile_speed, 0.0, "spell_fireball_small_blue", false, true, false,_,_,_,10.0);
						npc.FaceTowards(vecTarget, 20000.0);
						npc.m_flNextRangedAttack = gameTime + 6.5;
						npc.PlayRangedReloadSound();
					}
					
				}
			}
		}
	}
	npc.m_iTarget = GetClosestEnemyToAttack;
}
static void Fire_Hyper_Arrow(Aetherianus npc, float Npc_Vec[3], int target, float vecTarget[3])
{
	fl_ruina_battery[npc.index] = 0.0;
	npc.PlayHyperArrowSound();

	npc.AddGesture("ACT_MP_ATTACK_STAND_ITEM2", true);

	npc.FaceTowards(vecTarget, 20000.0);
	npc.m_flNextRangedAttack = GetGameTime(npc.index) + 8.5;
	npc.PlayRangedReloadSound();

	Ruina_Projectiles Projectile;
	float Projectile_Time = 2.5;

	float projectile_speed = 900.0;	
	float target_vec[3];
	PredictSubjectPositionForProjectiles(npc, target, projectile_speed, _,target_vec);

	Projectile.iNPC = npc.index;
	Projectile.Start_Loc = Npc_Vec;
	float Ang[3];
	MakeVectorFromPoints(Npc_Vec, target_vec, Ang);
	GetVectorAngles(Ang, Ang);
	Projectile.Angles = Ang;
	Projectile.speed = projectile_speed;
	Projectile.radius = 0.0;
	Projectile.damage = 200.0;
	Projectile.bonus_dmg = 300.0;
	Projectile.Time = Projectile_Time;
	Projectile.visible = false;
	int Proj = Projectile.Launch_Projectile(Func_On_Proj_Touch);

	if(!IsValidEntity(Proj))
		return;

	npc.m_flAttackHappens = GetGameTime(npc.index) + Projectile_Time;

	float 	Homing_Power = 2.5,
			Homing_Lockon = 25.0;

	Initiate_HomingProjectile(Proj,
	npc.index,
	Homing_Lockon,			// float lockonAngleMax,
	Homing_Power,			// float homingaSec,
	true,					// bool LockOnlyOnce,
	true,					// bool changeAngles,
	Ang);

	i_laz_entity[npc.index] = EntIndexToEntRef(Proj);


	float 	f_start = 3.5,
			f_end = 2.5,
			amp = 0.3;

	int color[4];
	Ruina_Color(color);
	
	//int beam_start = EntRefToEntIndex(i_particle_ref_id[npc.index][0]);
			
	int beam = ConnectWithBeamClient(npc.m_iWearable6, Proj, color[0], color[1], color[2], f_start, f_end, amp, LASERBEAM);
	i_WandParticle[Proj] = EntIndexToEntRef(beam);
}