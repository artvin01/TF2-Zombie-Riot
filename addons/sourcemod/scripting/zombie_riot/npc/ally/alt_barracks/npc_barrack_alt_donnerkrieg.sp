#pragma semicolon 1
#pragma newdecls required

static const char g_IdleSounds[][] =
{
	"vo/medic_battlecry01.mp3",
	"vo/medic_battlecry02.mp3",
	"vo/medic_battlecry03.mp3",
	"vo/medic_battlecry04.mp3",
};

static const char g_IdleAlertedSounds[][] =
{
	"vo/medic_battlecry01.mp3",
	"vo/medic_battlecry02.mp3",
	"vo/medic_battlecry03.mp3",
	"vo/medic_battlecry04.mp3",
};
static char g_PullSounds[][] = {
	"weapons/physcannon/superphys_launch1.wav",
	"weapons/physcannon/superphys_launch2.wav",
	"weapons/physcannon/superphys_launch3.wav",
	"weapons/physcannon/superphys_launch4.wav",
};


public void Barrack_Alt_Donnerkrieg_MapStart()
{
	PrecacheSoundArray(g_DefaultCapperShootSound);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Barracks Donnerkrieg");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_barrack_alt_donnerkrieg");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static float fl_npc_basespeed;

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return Barrack_Alt_Donnerkrieg(client, vecPos, vecAng);
}

methodmap Barrack_Alt_Donnerkrieg < BarrackBody
{
	property int m_iAmountProjectiles
	{
		public get()							{ return i_AmountProjectiles[this.index]; }
		public set(int TempValueForProperty) 	{ i_AmountProjectiles[this.index] = TempValueForProperty; }
	}
	property float m_flNorm_Attack_Duration
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property int m_iCannonActive
	{
		public get()							{ return this.m_iState; }
		public set(int TempValueForProperty) 	{ this.m_iState = TempValueForProperty; }
	}

	public void PlayPullSound() {
		EmitSoundToAll(g_PullSounds[GetRandomInt(0, sizeof(g_PullSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME*0.5);
	}
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		switch(GetRandomInt(0,3))
		{
			case 0:
			{
				NpcSpeechBubble(this.index, "I wonder what my homeland has been like", 5, {255,255,255,255}, {0.0,0.0,60.0}, "...");
			}
			case 1:
			{
				NpcSpeechBubble(this.index, "Wheres schwert at?", 5, {255,255,255,255}, {0.0,0.0,60.0}, "");
			}
			case 2:
			{
				NpcSpeechBubble(this.index, "Is ruina fine?", 5, {255,255,255,255}, {0.0,0.0,60.0}, "");
			}
			case 3:
			{
				NpcSpeechBubble(this.index, "A little nice and quiet.", 5, {255,255,255,255}, {0.0,0.0,60.0}, "");
			}
		}
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
	}
	public void PlayIdleAlertSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		switch(GetRandomInt(0,3))
		{
			case 0:
			{
				NpcSpeechBubble(this.index, "uh oh!", 5, {255,255,255,255}, {0.0,0.0,60.0}, "");
			}
			case 1:
			{
				NpcSpeechBubble(this.index, "The horde is relentless, ain't it?", 5, {255,255,255,255}, {0.0,0.0,60.0}, "");
			}
			case 2:
			{
				NpcSpeechBubble(this.index, "Im too tired to cast my main spell here.", 5, {255,255,255,255}, {0.0,0.0,60.0}, "");
			}
			case 3:
			{
				NpcSpeechBubble(this.index, "Hey, a little assistance over here", 5, {255,255,255,255}, {0.0,0.0,60.0}, "");
			}
		}
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayRangedSound() {
		EmitSoundToAll(g_DefaultCapperShootSound[GetRandomInt(0, sizeof(g_DefaultCapperShootSound) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	public Barrack_Alt_Donnerkrieg(int client, float vecPos[3], float vecAng[3])
	{
		Barrack_Alt_Donnerkrieg npc = view_as<Barrack_Alt_Donnerkrieg>(BarrackBody(client, vecPos, vecAng, "650", "models/player/medic.mdl", STEPTYPE_NORMAL,_,_,"models/pickups/pickup_powerup_precision.mdl"));
		
		i_NpcWeight[npc.index] = 1;
		
		func_NPCOnTakeDamage[npc.index] = BarrackBody_OnTakeDamage;
		func_NPCDeath[npc.index] = Barrack_Alt_Donnerkrieg_NPCDeath;
		func_NPCThink[npc.index] = Barrack_Alt_Donnerkrieg_ClotThink;

		fl_npc_basespeed = 250.0;
		npc.m_flSpeed = 250.0;
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/medic/Sbox2014_Medic_Colonel_Coat/Sbox2014_Medic_Colonel_Coat.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/medic/xms2013_medic_hood/xms2013_medic_hood.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/medic/hw2013_moon_boots/hw2013_moon_boots.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);
		
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/all_class/Jul13_Se_Headset/Jul13_Se_Headset_medic.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", 1);
		
		
		int skin = 1;	//1=blue, 0=red
		SetVariantInt(1);	
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);

		npc.m_flNorm_Attack_Duration=0.0;

		fl_BEAM_RechargeTime[npc.index] = GetGameTime(npc.index) + 10.0;
		
		AcceptEntityInput(npc.m_iWearable1, "Enable");

		npc.m_flNextIdleSound = GetGameTime(npc.index) + GetRandomFloat(2.0, 3.0);

		npc.m_iCannonActive = 0;
		
		return npc;
	}
}

public void Barrack_Alt_Donnerkrieg_ClotThink(int iNPC)
{
	Barrack_Alt_Donnerkrieg npc = view_as<Barrack_Alt_Donnerkrieg>(iNPC);
	float GameTime = GetGameTime(iNPC);
	if(npc.m_flNorm_Attack_Duration>GameTime)
	{
		if(!npc.m_iCannonActive)
			DonnerKrieg_Normal_Attack(npc);
	}
	if(!BarrackBody_ThinkStart(npc.index, GameTime))
		return;

	BarrackBody_ThinkTarget(npc.index, true, GameTime);
	int PrimaryThreatIndex = npc.m_iTarget;

	if(npc.m_iCannonActive)
	{
		float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		Barracks_Body_Pitch(npc, VecSelfNpc, vecTarget);


		npc.m_flRangedArmor = 0.5;
		npc.m_flMeleeArmor = 0.5;
		BarrackBody_ThinkMove(npc.index, 0.0, "ACT_GRAPPLE_PULL_IDLE", "ACT_GRAPPLE_PULL_IDLE", 100000.0, false, false);

		return;
	}
	else if(PrimaryThreatIndex < 0)
	{
		npc.PlayIdleSound();
		return;
	}
	npc.PlayIdleAlertSound();
	float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		
	Barracks_Body_Pitch(npc, VecSelfNpc, vecTarget);
	
	if(flDistanceToTarget < 250000 && fl_BEAM_RechargeTime[npc.index]<GameTime)
	{
		int Enemy_I_See;		
		Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
		if(IsValidEnemy(npc.index, Enemy_I_See))
		{
			int iActivity = npc.LookupActivity("ACT_GRAPPLE_PULL_IDLE");
			if(iActivity > 0) npc.StartActivity(iActivity);
			Invoke_Donner_NC(npc);
			npc.m_iCannonActive = true;
			fl_BEAM_RechargeTime[npc.index] = GameTime + 30.0*npc.BonusFireRate;
			return;
		}
	}

	if(npc.m_bAllowBackWalking)
		npc.FaceTowards(vecTarget);
	
	if(flDistanceToTarget < 100000 || npc.m_flAttackHappenswillhappen)
	{
		npc.m_bAllowBackWalking = true;
		//Look at target so we hit.
	//	npc.FaceTowards(vecTarget, 1000.0);
				
		//Can we attack right now?
		if(npc.m_flNextMeleeAttack < GameTime)
		{
			//Play attack ani
			if (!npc.m_flAttackHappenswillhappen)
			{
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
				npc.PlayPullSound();
				npc.m_flAttackHappens =  GameTime+0.4*npc.BonusFireRate;
				npc.m_flAttackHappens_bullshit =  GameTime+0.54*npc.BonusFireRate;
				npc.m_flAttackHappenswillhappen = true;
				npc.FaceTowards(vecTarget);

				npc.m_flNorm_Attack_Duration=GameTime+0.25;

			}
			if (npc.m_flAttackHappens_bullshit < GameTime && npc.m_flAttackHappenswillhappen)
			{
				npc.m_flAttackHappenswillhappen = false;
				npc.m_flNextMeleeAttack = GameTime+0.4*npc.BonusFireRate;
			}
		}
	}
	else
	{
		npc.StartPathing();
		npc.m_bAllowBackWalking = false;
	}
	int Enemy_I_See;		
	Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
	if(flDistanceToTarget < 300000 && IsValidEnemy(npc.index, Enemy_I_See))
	{
		if(npc.m_flNextRangedBarrage_Spam < GameTime && npc.m_flNextRangedBarrage_Singular < GameTime)
		{	
			npc.m_iAmountProjectiles += 1;
			npc.m_flNextRangedBarrage_Singular = GameTime + 0.1;
			npc.PlayRangedSound();
			
			float speed = 750.0;					
			float flPos[3]; // original
			float flAng[3]; // original
			GetAttachment(npc.index, "effect_hand_r", flPos, flAng);
			
			PredictSubjectPositionForProjectiles(npc, PrimaryThreatIndex, speed,_,vecTarget);					
			npc.FireParticleRocket(vecTarget, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId), 2200.0, 1) , 850.0 , 100.0 , "raygun_projectile_blue_crit", _, false, true, flPos, _ , GetClientOfUserId(npc.OwnerUserId));
			if (npc.m_iAmountProjectiles >= 15)
			{
				npc.m_iAmountProjectiles = 0;
				npc.m_flNextRangedBarrage_Spam = GameTime + 10.0 * npc.BonusFireRate;
			}
		}
	}
	BarrackBody_ThinkMove(npc.index, 250.0, "ACT_MP_RUN_MELEE", "ACT_MP_RUN_MELEE", 100000.0, _, false);
	if(npc.m_flNextMeleeAttack > GameTime)
	{
		npc.m_flSpeed = 10.0;
	}
	else
	{
		npc.m_flSpeed = fl_npc_basespeed;
	}
}

void Barrack_Alt_Donnerkrieg_NPCDeath(int entity)
{
	Barrack_Alt_Donnerkrieg npc = view_as<Barrack_Alt_Donnerkrieg>(entity);
	BarrackBody_NPCDeath(npc.index);
}

static void Invoke_Donner_NC(Barrack_Alt_Donnerkrieg npc)
{
	float GameTime = GetGameTime(npc.index);
	fl_BEAM_ChargeUpTime[npc.index] = GameTime + 1.0;
	fl_BEAM_DurationTime[npc.index] = GameTime + 10.0;
	SDKUnhook(npc.index, SDKHook_Think, Barracks_Donner_NC_Tick);
	SDKHook(npc.index, SDKHook_Think, Barracks_Donner_NC_Tick);
}

static Action Barracks_Donner_NC_Tick(int client)
{
	Barrack_Alt_Donnerkrieg npc = view_as<Barrack_Alt_Donnerkrieg>(client);
	float GameTime = GetGameTime(npc.index);
	if(!IsValidEntity(npc.index) || fl_BEAM_DurationTime[npc.index] < GameTime)
	{
		npc.m_iCannonActive = 0;

		npc.m_flRangedArmor = 1.0;
		npc.m_flMeleeArmor = 1.0;

		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0)
			npc.StartActivity(iActivity);

		SDKUnhook(npc.index, SDKHook_Think, Barracks_Donner_NC_Tick);
		return Plugin_Stop;
	}

	if(fl_BEAM_ChargeUpTime[npc.index] > GameTime)
		return Plugin_Continue;

	if(fl_BEAM_ThrottleTime[npc.index] > GameTime)
		return Plugin_Continue;

	fl_BEAM_ThrottleTime[npc.index] = GameTime + 0.1;

	Basic_Barracks_Laser Data;
	Data.npc = npc;
	Data.Radius = 5.0;
	Data.Range = 750.0;
	Data.Close_Dps = 3000.0;
	Data.Long_Dps = 2000.0;
	Data.Color = {194, 43, 43, 30};
	Data.DoEffects = true;
	Basic_Barracks_Laser_Logic(Data);

	return Plugin_Continue;
}
static void DonnerKrieg_Normal_Attack(Barrack_Alt_Donnerkrieg npc)
{
	Basic_Barracks_Laser Data;
	Data.npc = npc;
	Data.Radius = 5.0;
	Data.Range = 500.0;
	//divided by 6 since its every tick, and by TickrateModify
	Data.Close_Dps = 3000.0 / 6.0 / TickrateModify;
	Data.Long_Dps = 1500.0 / 6.0 / TickrateModify;
	Data.Color = {171, 218, 247, 30};
	Data.DoEffects = true;
	Basic_Barracks_Laser_Logic(Data);
}