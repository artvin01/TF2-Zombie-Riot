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
	"vo/sniper_painsharp05.mp3",
	"vo/sniper_painsharp06.mp3",
	"vo/sniper_painsharp07.mp3",
	"vo/sniper_painsharp08.mp3",
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
	"weapons/sniper_railgun_charged_shot_01.wav",
	"weapons/sniper_railgun_charged_shot_02.wav",
};

static const char g_RangedReloadSound[][] = {
	"weapons/sniper_railgun_world_reload.wav",
};

void Aether_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds));   i++) { PrecacheSound(g_RangedAttackSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedReloadSound));   i++) { PrecacheSound(g_RangedReloadSound[i]);   }
	PrecacheModel("models/player/sniper.mdl");
}

methodmap Aether < CClotBody
{
	
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleSound()");
		#endif
	}
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleAlertSound()");
		#endif
	}
	
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
	
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME-25, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayRangedSound()");
		#endif
	}
	public void PlayRangedReloadSound() {
		EmitSoundToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME-25, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayRangedSound()");
		#endif
	}
	
	
	public Aether(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		Aether npc = view_as<Aether>(CClotBody(vecPos, vecAng, "models/player/sniper.mdl", "1.0", "1250", ally));
		
		i_NpcInternalId[npc.index] = RUINA_AETHER;
		i_NpcWeight[npc.index] = 1;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_PRIMARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		/*
			
		
		*/
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		
		
		SDKHook(npc.index, SDKHook_Think, Aether_ClotThink);

		npc.m_flSpeed = 200.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_dex_sniperrifle/c_dex_sniperrifle.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		/*npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/sniper/hw2013_ramses_regalia/hw2013_ramses_regalia.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/sniper/hw2013_moon_boots/hw2013_moon_boots.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/sniper/xms2013_sniper_robe/xms2013_sniper_robe.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		
		
		int skin = 1;	//1=blue, 0=red
		SetVariantInt(1);	
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);*/
				
				
		fl_ruina_battery[npc.index] = 0.0;
		b_ruina_battery_ability_active[npc.index] = false;
		fl_ruina_battery_timer[npc.index] = 0.0;
		
		Ruina_Set_Heirarchy(npc.index, 2);	//is a ranged npc

		return npc;
	}
	
	
}

//TODO 
//Rewrite
public void Aether_ClotThink(int iNPC)
{
	Aether npc = view_as<Aether>(iNPC);
	
	float GameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > GameTime)
	{
		return;
	}
	
	Ruina_Add_Battery(npc.index, 5.0);
	
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
	
	if(fl_ruina_battery[npc.index]>500.0)
	{
		fl_ruina_battery[npc.index] = 0.0;
		
	}

	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
			
		int Anchor_Id=-1;
		Ruina_Independant_Long_Range_Npc_Logic(npc.index, PrimaryThreatIndex, GameTime, Anchor_Id); //handles movement

		float vecTarget[3]; vecTarget = WorldSpaceCenter(PrimaryThreatIndex);
		
		float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
			
		if(!IsValidEntity(Anchor_Id))
		{
			if(flDistanceToTarget < 100000)
			{
				if(flDistanceToTarget < (50000))
				{
					Ruina_Runaway_Logic(npc.index, PrimaryThreatIndex);
				}
				else
				{
					NPC_StopPathing(npc.index);
					npc.m_bPathing = false;
				}
			}
			else
			{
				npc.StartPathing();
				npc.m_bPathing = true;
			}
		}
		
		Aether_SelfDefense(npc, GameTime, Anchor_Id);
	}
	else
	{
		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action Aether_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Aether npc = view_as<Aether>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	fl_ruina_battery[npc.index] += damage;	//turn damage taken into energy
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void Aether_NPCDeath(int entity)
{
	Aether npc = view_as<Aether>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	SDKUnhook(npc.index, SDKHook_Think, Aether_ClotThink);
		
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
}

static void Aether_SelfDefense(Aether npc, float gameTime, int Anchor_Id)	//ty artvin
{
	int GetClosestEnemyToAttack;
	//Ranged units will behave differently.
	//Get the closest visible target via distance checks, not via pathing check.
	GetClosestEnemyToAttack = GetClosestTarget(npc.index,_,_,_,_,_,_,true,_,_,true);	//works with masters, slaves not so much. seems to work with independant npc's too
	if(!IsValidEnemy(npc.index,GetClosestEnemyToAttack))	//no target, what to do while idle
	{
		return;
	}
	float vecTarget[3]; vecTarget = WorldSpaceCenter(GetClosestEnemyToAttack);

	float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
	if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 30.0))
	{	
		//target is within range, attack them
		if(flDistanceToTarget <(NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 15.0))
		{
			Ruina_Runaway_Logic(npc.index, GetClosestEnemyToAttack);
		}
		else
		{
			if(gameTime > npc.m_flNextRangedAttack)
			{
				npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY", true);
				npc.PlayRangedSound();
				//after we fire, we will have a short delay beteween the actual laser, and when it happens
				//This will predict as its relatively easy to dodge
				float projectile_speed = 1250.0;
				//lets pretend we have a projectile.
				vecTarget = PredictSubjectPositionForProjectiles(npc, GetClosestEnemyToAttack, projectile_speed, 40.0);
				if(!Can_I_See_Enemy_Only(npc.index, GetClosestEnemyToAttack)) //cant see enemy in the predicted position, we will instead just attack normally
				{
					vecTarget = WorldSpaceCenter(GetClosestEnemyToAttack);
				}
				float DamageDone = 25.0;
				npc.FireParticleRocket(vecTarget, DamageDone, projectile_speed, 0.0, "raygun_projectile_blue", false, true, false,_,_,_,10.0);
				npc.FaceTowards(vecTarget, 20000.0);
				npc.m_flNextRangedAttack = GetGameTime(npc.index) + 2.75;
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
				GetClosestEnemyToAttack = target;
				if(gameTime > npc.m_flNextRangedAttack)
				{
					npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY", true);
					npc.PlayRangedSound();
					//after we fire, we will have a short delay beteween the actual laser, and when it happens
					//This will predict as its relatively easy to dodge
					float projectile_speed = 1250.0;
					//lets pretend we have a projectile.
					vecTarget = PredictSubjectPositionForProjectiles(npc, GetClosestEnemyToAttack, projectile_speed, 40.0);
					if(!Can_I_See_Enemy_Only(npc.index, GetClosestEnemyToAttack)) //cant see enemy in the predicted position, we will instead just attack normally
					{
						vecTarget = WorldSpaceCenter(GetClosestEnemyToAttack);
					}
					float DamageDone = 25.0;
					npc.FireParticleRocket(vecTarget, DamageDone, projectile_speed, 0.0, "raygun_projectile_blue", false, true, false,_,_,_,10.0);
					npc.FaceTowards(vecTarget, 20000.0);
					npc.m_flNextRangedAttack = GetGameTime(npc.index) + 2.75;
					npc.PlayRangedReloadSound();
				}
			}
		}
	}
	npc.m_iTarget = GetClosestEnemyToAttack;
}