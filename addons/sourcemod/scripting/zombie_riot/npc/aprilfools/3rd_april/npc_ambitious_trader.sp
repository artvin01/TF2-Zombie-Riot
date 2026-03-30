#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"npc/metropolice/die1.wav",
	"npc/metropolice/die2.wav",
	"npc/metropolice/die3.wav",
	"npc/metropolice/die4.wav",
};

static const char g_HurtSounds[][] = {
	"npc/metropolice/pain1.wav",
	"npc/metropolice/pain2.wav",
	"npc/metropolice/pain3.wav",
	"npc/metropolice/pain4.wav",
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
	"weapons/blade_slice_2.wav",
	"weapons/blade_slice_3.wav",
	"weapons/blade_slice_4.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/shovel_swing.wav",
};

void AmbitiousTrader_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_DefaultMeleeMissSounds));   i++) { PrecacheSound(g_DefaultMeleeMissSounds[i]);   }
	PrecacheModel(COMBINE_CUSTOM_MODEL);
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "A Man Who Is Really Ambitious About Team Fortress 2 Trading");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_ambitious_trader");
	strcopy(data.Icon, sizeof(data.Icon), "scout");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Mutation;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return AmbitiousTrader(vecPos, vecAng, team);
}
methodmap AmbitiousTrader < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
		

	}
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		
		
		
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		
		
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		

	}
	
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		

	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_DefaultMeleeMissSounds[GetRandomInt(0, sizeof(g_DefaultMeleeMissSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		
		
	}
	
	public AmbitiousTrader(float vecPos[3], float vecAng[3], int ally)
	{
		AmbitiousTrader npc = view_as<AmbitiousTrader>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", "5000", ally));
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		i_NpcWeight[npc.index] = 3;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_CUSTOM_WALK_LUCIAN");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE_METRO;
		
		
		func_NPCDeath[npc.index] = AmbitiousTrader_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = AmbitiousTrader_OnTakeDamage;
		func_NPCThink[npc.index] = AmbitiousTrader_ClotThink;

		npc.m_iState = 0;
		npc.m_flSpeed = 300.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_fbRangedSpecialOn = false;
		npc.m_iHealthBar = 4;
		
		npc.m_flMeleeArmor = 0.25;
		npc.m_flRangedArmor = 0.25;
		f_AttackSpeedNpcIncrease[npc.index] = 0.25;

		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_claymore/c_claymore.mdl");
		SetVariantString("0.9");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("weapon_bone", "models/player/items/engineer/engineer_earbuds.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		npc.m_iWearable3 = npc.EquipItem("partyhat", "models/workshop/player/items/all_class/jul13_sweet_shades_s1/jul13_sweet_shades_s1_engineer.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		npc.m_iWearable4 = npc.EquipItem("partyhat", "models/player/items/engineer/hat_first_nr.mdl");
		SetVariantString("1.1");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");

		npc.m_iWearable5 = npc.EquipItem("head", "models/player/items/engineer/scarf_soccer.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");

		npc.StartPathing();

		switch(GetRandomInt(0,2))
		{
			case 0:
				CPrintToChatAll("{valve}A Man Who Is Really Ambitious About Team Fortress 2 Trading{default}: Aight I got like uh, one key on me I think? Anyone up for a trade?");
			case 1:
				CPrintToChatAll("{valve}A Man Who Is Really Ambitious About Team Fortress 2 Trading{default}: Stout Shako for 2 refined, any takers?");
			case 2:
				CPrintToChatAll("{valve}A Man Who Is Really Ambitious About Team Fortress 2 Trading{default}: God bless Valve for providing us with the ability to trade. Like, how awesome is that?");
		}
		
		return npc;
	}
}


public void AmbitiousTrader_ClotThink(int iNPC)
{
	AmbitiousTrader npc = view_as<AmbitiousTrader>(iNPC);

	float gameTime = GetGameTime(iNPC);

	if(npc.m_flNextDelayTime > gameTime)
	{
		return;
	}
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();	
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_GESTURE_FLINCH_HEAD", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > gameTime)
	{
		return;
	}
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
	}

	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			if(IsValidEnemy(npc.index, npc.m_iTarget))
			{
				Handle swingTrace;
				float TargetVecPos[3]; WorldSpaceCenter(npc.m_iTarget, TargetVecPos);
				npc.FaceTowards(TargetVecPos, 15000.0); 
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, _)) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
				{
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					float damage = 45.0;

					if(ShouldNpcDealBonusDamage(target))
					{
						damage *= 3.0;
					}
					
					if(target > 0) 
					{
						npc.PlayMeleeHitSound();
						SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB, -1, _, vecHit);
					}
				}
				delete swingTrace;
			}
		}
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
			
		//Predict their pos.
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3]; PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
			
			npc.SetGoalVector(vPredictedPos);
		}
		else
		{
			npc.SetGoalEntity(npc.m_iTarget);
		}
		//Get position for just travel here.

		if(npc.m_flDoingAnimation > gameTime) //I am doing an animation or doing something else, default to doing nothing!
		{
			npc.m_iState = -1;
		}
		else if(flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED && npc.m_flNextMeleeAttack < gameTime)
		{
			npc.m_iState = 1; //Engage in Close Range Destruction.
		}
		else 
		{
			npc.m_iState = 0; //stand and look if close enough.
		}
		
		switch(npc.m_iState)
		{
			case -1:
			{
				return; //Do nothing.
			}
			case 0:
			{
				//Walk to target
				if(!npc.m_bPathing)
					npc.StartPathing();
					
				if(npc.m_iChanged_WalkCycle != 4) 	
				{
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity("ACT_CUSTOM_WALK_LUCIAN");
				}
			}
			case 1:
			{			
				int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				//Can i see This enemy, is something in the way of us?
				//Dont even check if its the same enemy, just engage in killing, and also set our new target to this just in case.
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.m_iTarget = Enemy_I_See;

					npc.AddGesture("ACT_CUSTOM_ATTACK_SWORD");
					

					npc.PlayMeleeSound();
					
					npc.m_flAttackHappens = gameTime + 0.35;

					npc.m_flDoingAnimation = gameTime + 0.35;
					npc.m_flNextMeleeAttack = gameTime + 1.5;
				}
			}
		}
	}
	else
	{
		npc.StopPathing();
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleSound();
}

public Action AmbitiousTrader_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	AmbitiousTrader npc = view_as<AmbitiousTrader>(victim);
	
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	if(npc.m_iHealthBar <= 0 && !npc.Anger)
	{
		npc.Anger = true;
		npc.m_flMeleeArmor = 1.25;
		npc.m_flRangedArmor = 1.25;
		f_AttackSpeedNpcIncrease[npc.index] = 1.25;
		if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
		switch(GetRandomInt(0,2))
		{
			case 0:
				CPrintToChatAll("{valve}A Man Who Is Really Ambitious About Team Fortress 2 Trading{default}: YOU RAPSCALLION BASTARDS, CAN A MAN HAVE NOTHING IN HIS LIFE?");
			case 1:
				CPrintToChatAll("{valve}A Man Who Is Really Ambitious About Team Fortress 2 Trading{default}: FUCK. YOU. FUCK ALL OF YOU, I HOPE ALL OF YOU BURN TO THE GROUND");
			case 2:
				CPrintToChatAll("{valve}A Man Who Is Really Ambitious About Team Fortress 2 Trading{default}: HOP OFF, MAYBE YOU SHOULD TRY PURSUING A HOBBY INSTEAD OF BULLYING AN INNOCENT MAN");
		}
		CPrintToChatAll("He weakens as you defeat his hats.");
	}
	if(npc.m_iHealthBar <= 1 && !npc.m_bFUCKYOU)
	{
		npc.m_bFUCKYOU = true;
		npc.m_flMeleeArmor = 1.0;
		npc.m_flRangedArmor = 1.0;
		f_AttackSpeedNpcIncrease[npc.index] = 1.0;
		if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
		switch(GetRandomInt(0,2))
		{
			case 0:
				CPrintToChatAll("{valve}A Man Who Is Really Ambitious About Team Fortress 2 Trading{default}: Is this some sort of sick thing that gets you off? You fucking weirdos.");
			case 1:
				CPrintToChatAll("{valve}A Man Who Is Really Ambitious About Team Fortress 2 Trading{default}: I'm going to kill each and everyone of you.");
			case 2:
				CPrintToChatAll("{valve}A Man Who Is Really Ambitious About Team Fortress 2 Trading{default}: Alright, you've asked for it. Sorry old lady, this is why I never make promises.");
		}
		CPrintToChatAll("He weakens as you defeat his hats.");
	}
	if(npc.m_iHealthBar <= 2 && !npc.m_bWasSadAlready)
	{
		npc.m_bWasSadAlready = true;
		npc.m_flMeleeArmor = 0.75;
		npc.m_flRangedArmor = 0.75;
		f_AttackSpeedNpcIncrease[npc.index] = 0.75;
		if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
		switch(GetRandomInt(0,2))
		{
			case 0:
				CPrintToChatAll("{valve}A Man Who Is Really Ambitious About Team Fortress 2 Trading{default}: People like you are the reason why the economy is failing. Stop that.");
			case 1:
				CPrintToChatAll("{valve}A Man Who Is Really Ambitious About Team Fortress 2 Trading{default}: Stop. Killing. My. Hats.");
			case 2:
				CPrintToChatAll("{valve}A Man Who Is Really Ambitious About Team Fortress 2 Trading{default}: You are getting on my nerves. Leave my hats alone.");
		}
		CPrintToChatAll("He weakens as you defeat his hats.");
	}
	if(npc.m_iHealthBar <= 3 && !npc.m_bFUCKYOU_move_anim)
	{
		npc.m_bFUCKYOU_move_anim = true;
		npc.m_flMeleeArmor = 0.50;
		npc.m_flRangedArmor = 0.50;
		f_AttackSpeedNpcIncrease[npc.index] = 0.50;
		if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
		switch(GetRandomInt(0,2))
		{
			case 0:
				CPrintToChatAll("{valve}A Man Who Is Really Ambitious About Team Fortress 2 Trading{default}: Oh you did not just do that. You did NOT just do that.");
			case 1:
				CPrintToChatAll("{valve}A Man Who Is Really Ambitious About Team Fortress 2 Trading{default}: You're kidding right?");
			case 2:
				CPrintToChatAll("{valve}A Man Who Is Really Ambitious About Team Fortress 2 Trading{default}: Do you have ANY idea how much any of this costs?!");
		}
		CPrintToChatAll("He weakens as you defeat his hats.");	
	}
	
	
	return Plugin_Changed;
}

public void AmbitiousTrader_NPCDeath(int entity)
{
	AmbitiousTrader npc = view_as<AmbitiousTrader>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
		
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
}