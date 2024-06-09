#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/demoman_paincrticialdeath01.mp3",
	"vo/demoman_paincrticialdeath02.mp3",
	"vo/demoman_paincrticialdeath03.mp3",
	"vo/demoman_paincrticialdeath04.mp3",
	"vo/demoman_paincrticialdeath05.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/demoman_painsharp01.mp3",
	"vo/demoman_painsharp02.mp3",
	"vo/demoman_painsharp03.mp3",
	"vo/demoman_painsharp04.mp3",
	"vo/demoman_painsharp05.mp3",
	"vo/demoman_painsharp06.mp3",
	"vo/demoman_painsharp07.mp3",
};
static const char g_IdleAlertedSounds[][] = {
	"vo/demoman_battlecry01.mp3",
	"vo/demoman_battlecry02.mp3",
	"vo/demoman_battlecry03.mp3",
	"vo/demoman_battlecry04.mp3",
};
static const char g_MeleeAttackSounds[][] = {
	"weapons/physcannon/superphys_launch1.wav",
	"weapons/physcannon/superphys_launch2.wav",
	"weapons/physcannon/superphys_launch3.wav",
	"weapons/physcannon/superphys_launch4.wav",
};
static const char g_RangedReloadSound[][] = {
	"weapons/dragons_fury_pressure_build.wav",
};

void Lazius_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Lazius");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_ruina_lazius");
	data.Category = Type_Ruina;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	strcopy(data.Icon, sizeof(data.Icon), "demo"); 						//leaderboard_class_(insert the name)
	data.IconCustom = false;												//download needed?
	data.Flags = 0;						//example: MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;, forces these flags.	
	NPC_Add(data);
}
static void ClotPrecache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_RangedReloadSound);
	PrecacheModel("models/player/demo.mdl");
}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return Lazius(client, vecPos, vecAng, ally);
}

methodmap Lazius < CClotBody
{	
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
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}

	public void PlayRangedReloadSound() {
		EmitSoundToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayRangedSound()");
		#endif
	}
	
	
	public Lazius(int client, float vecPos[3], float vecAng[3], int ally)
	{
		Lazius npc = view_as<Lazius>(CClotBody(vecPos, vecAng, "models/player/demo.mdl", "1.0", "1250", ally));
		
		i_NpcWeight[npc.index] = 1;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_SECONDARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		/*
			Bozo's bouffant		"models/workshop/player/items/pyro/hw2013_the_haha_hairdo/hw2013_the_haha_hairdo.mdl"
			Last Breath			"models/workshop/player/items/pyro/pyro_halloween_gasmask/pyro_halloween_gasmask.mdl"
			Masked Loyalty		"models/workshop/player/items/pyro/dec23_masked_loyalty/dec23_masked_loyalty.mdl"
			Mighty Mitre		"models/workshop/player/items/medic/dec18_mighty_mitre/dec18_mighty_mitre.mdl"
			Nostrum Napalmer	"models/workshop_partner/weapons/c_models/c_ai_flamethrower/c_ai_flamethrower.mdl"
			Wings of purity		"models/workshop/player/items/medic/sf14_purity_wings/sf14_purity_wings.mdl"
		
		*/
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(NPC_Death);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(ClotThink);

		npc.m_flSpeed = 285.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/pyro/hw2013_the_haha_hairdo/hw2013_the_haha_hairdo.mdl");
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/pyro/pyro_halloween_gasmask/pyro_halloween_gasmask.mdl");
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/pyro/dec23_masked_loyalty/dec23_masked_loyalty.mdl");	
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/medic/dec18_mighty_mitre/dec18_mighty_mitre.mdl");	
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop_partner/weapons/c_models/c_ai_flamethrower/c_ai_flamethrower.mdl");
		npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/medic/sf14_purity_wings/sf14_purity_wings.mdl");

		
		int skin = 1;	//1=blue, 0=red
		SetVariantInt(1);	
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", skin);
				
		npc.m_flNextTeleport = GetGameTime(npc.index) + 1.0;
				
		fl_ruina_battery[npc.index] = 0.0;
		b_ruina_battery_ability_active[npc.index] = false;
		fl_ruina_battery_timer[npc.index] = 0.0;
		
		Ruina_Set_Heirarchy(npc.index, RUINA_RANGED_NPC);	//is a RANGED npc
		
		return npc;
	}
	
	
}

//TODO 
//Rewrite
static void ClotThink(int iNPC)
{
	Lazius npc = view_as<Lazius>(iNPC);
	
	float GameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > GameTime)
	{
		return;
	}
	
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

	Ruina_Add_Battery(npc.index, 0.75);
	
	int PrimaryThreatIndex = npc.m_iTarget;	//when the npc first spawns this will obv be invalid, the core handles this.

	Ruina_Ai_Override_Core(npc.index, PrimaryThreatIndex, GameTime);	//handles movement, also handles targeting
	
	/*if(fl_ruina_battery[npc.index]>500.0)
	{
		fl_ruina_battery[npc.index] = 0.0;
		fl_ruina_battery_timer[npc.index] = GameTime + 2.5;
		
	}
	if(fl_ruina_battery_timer[npc.index]>GameTime)	//apply buffs
	{
		
	}*/
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))	//a final final failsafe
	{
		float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
		float Npc_Vec[3]; WorldSpaceCenter(npc.index, Npc_Vec);
		float flDistanceToTarget = GetVectorDistance(vecTarget, Npc_Vec, true);

		int iPitch = npc.LookupPoseParameter("body_pitch");
		if(iPitch < 0)
			return;		
						
		//Body pitch
		float v[3], ang[3];
		SubtractVectors(Npc_Vec, vecTarget, v); 
		NormalizeVector(v, v);
		GetVectorAngles(v, ang); 
								
		float flPitch = npc.GetPoseParameter(iPitch);
								
		npc.SetPoseParameter(iPitch, ApproachAngle(ang[0], flPitch, 10.0));

		if(flDistanceToTarget < (500.0*500.0))
		{
			int Enemy_I_See;
			
			Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
			//Target close enough to hit
			if(IsValidEnemy(npc.index, Enemy_I_See)) //Check if i can even see.
			{
				if(flDistanceToTarget < (325.0*350.0))
				{
					Ruina_Runaway_Logic(npc.index, PrimaryThreatIndex);
					npc.m_bAllowBackWalking=true;
				}
				else
				{
					NPC_StopPathing(npc.index);
					npc.m_bPathing = false;
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
			npc.StartPathing();
			npc.m_bPathing = true;
			npc.m_bAllowBackWalking=false;
		}

		//note: redo this so its basically not a copy of the pistoleers from expidonsa...
		if(npc.m_flNextRangedAttack < GameTime)	//Initialize the attack.
		{
			if(flDistanceToTarget<(500.0*500.0))
			{
				float Charge_Time = 2.5;	//how long it takes to fire the laser
				npc.m_flAttackHappens = Charge_Time + 1.0 + GameTime;	//show the laser visuals
				npc.m_flNextRangedBarrage_Spam = GameTime + Charge_Time-1.0;	//for how long can the npc turn until it stops turning towards the target
				npc.m_flNextMeleeAttack = GameTime + Charge_Time;
				npc.m_flNextRangedAttack = GameTime + 10.0;
				npc.PlayRangedReloadSound();
			}
		}
		if(npc.m_flAttackHappens > GameTime)	//attack is active
		{
			int color[4];
			float time=0.1;
			float size[2];
			float amp = 0.1;
			color = {175, 175, 175, 255};
			size[0] = 7.5; size[1] = 5.0;

			if(npc.m_flNextRangedBarrage_Spam > GameTime)	//turn towards enemy
			{
				npc.FaceTowards(vecTarget, 20000.0);
			}
			else
			{
				color = {100, 255, 100, 255};
				size[0] = 7.5; size[1] = 5.0;
				amp = 1.0;
				time = 0.2;
				npc.FaceTowards(vecTarget, 175.0);
			}

			

			bool attack=false;
			if(npc.m_flNextMeleeAttack < GameTime)	//attack!
			{
				npc.m_flAttackHappens = 0.0;
				color = {127, 255, 255, 255};
				time = 0.5;
				size[0] = 15.0; size[1] = 7.5;
				attack=true;
				amp = 5.0;
				npc.PlayMeleeSound();
				
			}

			Ruian_Laser_Logic Laser;

			Laser.client = npc.index;
			Laser.DoForwardTrace_Basic(975.0);

			float flPos[3], flAng[3]; // original
			GetAttachment(npc.index, "effect_hand_r", flPos, flAng);

			TE_SetupBeamPoints(flPos, Laser.End_Point, Ruina_BEAM_Laser, 0, 0, 0, time, size[0], size[1], 0, amp, color, 0);
			TE_SendToAll();

			if(attack)
			{
				float Npc_Loc[3];
				WorldSpaceCenter(npc.index, Npc_Loc);
				float dmg = 50.0;
				float radius = 25.0;

				Laser.Radius = radius;
				Laser.Damage = dmg;
				Laser.Bonus_Damage = dmg*6.0;

				Laser.Deal_Damage();
			}
		}
		else
		{
			if(npc.m_bAllowBackWalking)
				npc.FaceTowards(vecTarget, 2000.0);
		}
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

	Lazius npc = view_as<Lazius>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	Ruina_NPC_OnTakeDamage_Override(npc.index, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
	Ruina_Add_Battery(npc.index, damage);	//turn damage taken into energy
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static void NPC_Death(int entity)
{
	Lazius npc = view_as<Lazius>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	Ruina_NPCDeath_Override(entity);
		
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