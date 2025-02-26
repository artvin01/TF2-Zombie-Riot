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

void Aetheria_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Aetheria");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_ruina_aetheria");
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
	return Aetheria(vecPos, vecAng, team);
}

static float fl_npc_basespeed;
methodmap Aetheria < CClotBody
{
	
	public void PlayHyperArrowSound() {
		EmitSoundToAll(g_HyperArrowSound[GetRandomInt(0, sizeof(g_HyperArrowSound) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayHyperArrowSound()");
		#endif
	}

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
	
	
	public Aetheria(float vecPos[3], float vecAng[3], int ally)
	{
		Aetheria npc = view_as<Aetheria>(CClotBody(vecPos, vecAng, "models/player/sniper.mdl", "1.0", "1250", ally));

		i_NpcWeight[npc.index] = 1;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_ITEM2");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		/*
			//Blighted beak 			"models/player/items/medic/medic_blighted_beak.mdl"
			//Whiskey Bib				"models/workshop/player/items/demo/jul13_gallant_gael/jul13_gallant_gael.mdl"
			//Intangible Ascot 			"models/player/items/spy/hwn_spy_misc2.mdl"
			//Gentleman's Ushanka		"models/player/items/medic/medic_ushanka.mdl"
			//power spike 				"models/workshop/player/items/medic/hwn2023_power_spike/hwn2023_power_spike.mdl"
			//Triggerman's tacticals	"models/workshop/player/items/sniper/short2014_sniper_cargo_pants/short2014_sniper_cargo_pants.mdl"
		
		*/

		SetVariantInt(2);	
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(NPC_Death);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(ClotThink);

		fl_npc_basespeed = 200.0;
		npc.m_flSpeed = fl_npc_basespeed;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();

		static const char Items[][] = {
			"models/player/items/medic/medic_blighted_beak.mdl",
			"models/workshop/player/items/demo/jul13_gallant_gael/jul13_gallant_gael.mdl",
			"models/player/items/spy/hwn_spy_misc2.mdl",
			"models/player/items/medic/medic_ushanka.mdl",
			"models/workshop/player/items/medic/hwn2023_power_spike/hwn2023_power_spike.mdl",
			"models/workshop/player/items/sniper/short2014_sniper_cargo_pants/short2014_sniper_cargo_pants.mdl",
			RUINA_CUSTOM_MODELS_1
		};

		int skin = 1;	//1=blue, 0=red
		SetVariantInt(1);	
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		npc.m_iWearable1 = npc.EquipItem("head", Items[0], _, skin);
		npc.m_iWearable2 = npc.EquipItem("head", Items[1], _, skin);
		npc.m_iWearable3 = npc.EquipItem("head", Items[2], _, skin);
		npc.m_iWearable4 = npc.EquipItem("head", Items[3], _, skin);
		npc.m_iWearable5 = npc.EquipItem("head", Items[4], _, skin);
		npc.m_iWearable6 = npc.EquipItem("head", Items[5], _, skin);
		npc.m_iWearable7 = npc.EquipItem("head", Items[6]);

		SetVariantInt(RUINA_QUINCY_BOW_1);
		AcceptEntityInput(npc.m_iWearable7, "SetBodyGroup");	
			
		fl_ruina_battery[npc.index] = 0.0;
		b_ruina_battery_ability_active[npc.index] = false;
		fl_ruina_battery_timer[npc.index] = 0.0;
		
		Ruina_Set_Heirarchy(npc.index, RUINA_RANGED_NPC);	//is a ranged npc

		return npc;
	}
	
	
}


static void ClotThink(int iNPC)
{
	Aetheria npc = view_as<Aetheria>(iNPC);
	
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
						NPC_StopPathing(npc.index);
						npc.m_bAllowBackWalking=false;
						npc.m_bPathing = false;
					}
				}
				else
				{
					npc.StartPathing();
					npc.m_bPathing = true;
					npc.m_bAllowBackWalking=false;
				}
			}
			else
			{
				npc.StartPathing();
				npc.m_bPathing = true;
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
		
		Aetheria_SelfDefense(npc, GameTime, Anchor_Id);
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

static Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Aetheria npc = view_as<Aetheria>(victim);
		
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
	Aetheria npc = view_as<Aetheria>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}

	Ruina_NPCDeath_Override(npc.index);

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
	if(IsValidEntity(npc.m_iWearable7))
		RemoveEntity(npc.m_iWearable7);
}
static void Aetheria_SelfDefense(Aetheria npc, float gameTime, int Anchor_Id)	//ty artvin
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
	
	if(flDistanceToTarget < (1500.0*1500.0))
	{	
		if(gameTime > npc.m_flNextRangedAttack)
		{
			fl_ruina_in_combat_timer[npc.index]=gameTime+5.0;
			npc.AddGesture("ACT_MP_ATTACK_STAND_ITEM2", true);
			npc.PlayRangedSound();
			//after we fire, we will have a short delay beteween the actual laser, and when it happens
			//This will predict as its relatively easy to dodge
			float projectile_speed = 2000.0;
			//lets pretend we have a projectile.
			WorldSpaceCenter(GetClosestEnemyToAttack, vecTarget);
			float DamageDone = 50.0;
			npc.FireParticleRocket(vecTarget, DamageDone, projectile_speed, 0.0, "spell_fireball_small_blue", false, true, false,_,_,_,10.0);
			npc.FaceTowards(vecTarget, 20000.0);
			npc.m_flNextRangedAttack = GetGameTime(npc.index) + 7.5;	
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
					npc.AddGesture("ACT_MP_ATTACK_STAND_ITEM2", true);
					npc.PlayRangedSound();
					//after we fire, we will have a short delay beteween the actual laser, and when it happens
					//This will predict as its relatively easy to dodge
					float projectile_speed = 2000.0;
					//lets pretend we have a projectile.
					WorldSpaceCenter(GetClosestEnemyToAttack, vecTarget);
					float DamageDone = 50.0;
					npc.FireParticleRocket(vecTarget, DamageDone, projectile_speed, 0.0, "spell_fireball_small_blue", false, true, false,_,_,_,10.0);
					npc.FaceTowards(vecTarget, 20000.0);
					npc.m_flNextRangedAttack = GetGameTime(npc.index) + 7.5;
					npc.PlayRangedReloadSound();			
				}
			}
		}
	}
	npc.m_iTarget = GetClosestEnemyToAttack;
}