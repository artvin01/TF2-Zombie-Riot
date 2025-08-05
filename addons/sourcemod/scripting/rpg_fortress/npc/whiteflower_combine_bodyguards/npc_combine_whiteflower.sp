#pragma semicolon 1
#pragma newdecls required

// this should vary from npc to npc as some are in a really small area.

static char g_DeathSounds[][] = {
	"npc/combine_soldier/die1.wav",
	"npc/combine_soldier/die2.wav",
	"npc/combine_soldier/die3.wav",
};

static char g_HurtSound[][] = {
	"npc/combine_soldier/pain1.wav",
	"npc/combine_soldier/pain2.wav",
	"npc/combine_soldier/pain3.wav",
};

static char g_IdleSound[][] = {
	"npc/combine_soldier/vo/alert1.wav",
	"npc/combine_soldier/vo/bouncerbouncer.wav",
	"npc/combine_soldier/vo/boomer.wav",
	"npc/combine_soldier/vo/contactconfim.wav",
};


static char g_IdleAlertedSounds[][] = {
	"npc/metropolice/vo/chuckle.wav",
};

static char g_MeleeAttackSounds[][] = {
	"weapons/demo_sword_swing1.wav",
	"weapons/demo_sword_swing2.wav",
	"weapons/demo_sword_swing3.wav",
};

static char g_MeleeHitSounds[][] = {
	
	"weapons/blade_slice_2.wav",
	"weapons/blade_slice_3.wav",
	"weapons/blade_slice_4.wav",
};
static char g_RangedAttackSoundsSecondary[][] = {
	"common/wpn_hudoff.wav",
};
static char g_RocketSound[][] = {
	"weapons/rpg/rocketfire1.wav",
};
static const char g_HealSound[][] = {
	"items/medshot4.wav",
};

static bool b_TouchedEnemyTarget[MAXENTITIES];
public void Whiteflower_Boss_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_IdleSound));	i++) { PrecacheSound(g_IdleSound[i]);	}
	for (int i = 0; i < (sizeof(g_HurtSound));	i++) { PrecacheSound(g_HurtSound[i]);	}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds));	i++) { PrecacheSound(g_IdleAlertedSounds[i]);	}
	for (int i = 0; i < (sizeof(g_RangedAttackSoundsSecondary));	i++) { PrecacheSound(g_RangedAttackSoundsSecondary[i]);	}
	for (int i = 0; i < (sizeof(g_RocketSound));	i++) { PrecacheSound(g_RocketSound[i]);	}
	for (int i = 0; i < (sizeof(g_HealSound)); i++) { PrecacheSound(g_HealSound[i]); }
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Whiteflower");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_whiteflower_boss");
	data.Func = ClotSummon;
	NPC_Add(data);
	PrecacheSound("plats/tram_hit4.wav");
	PrecacheModel("models/props_lakeside_event/bomb_temp.mdl");
	PrecacheSoundCustom("rpg_fortress/enemy/whiteflower_dash.mp3");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return Whiteflower_Boss(vecPos, vecAng, team, data);
}

methodmap Whiteflower_Boss < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;

		EmitSoundToAll(g_IdleSound[GetRandomInt(0, sizeof(g_IdleSound) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);

		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
	}
	
	public void PlayHurtSound()
	{
		EmitSoundToAll(g_HurtSound[GetRandomInt(0, sizeof(g_HurtSound) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);
	}
	public void PlayRangedAttackSecondarySound() {
		EmitSoundToAll(g_RangedAttackSoundsSecondary[GetRandomInt(0, sizeof(g_RangedAttackSoundsSecondary) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 50);
		EmitSoundToAll(g_RangedAttackSoundsSecondary[GetRandomInt(0, sizeof(g_RangedAttackSoundsSecondary) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 50);
		EmitSoundToAll(g_RangedAttackSoundsSecondary[GetRandomInt(0, sizeof(g_RangedAttackSoundsSecondary) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 50);
		EmitSoundToAll(g_RocketSound[GetRandomInt(0, sizeof(g_RocketSound) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,150);
		

	}
	public void PlayHealSound() 
	{
		EmitSoundToAll(g_HealSound[GetRandomInt(0, sizeof(g_HealSound) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME - 0.1, 110);

	}
	public void PlayRocketSound()
 	{
		EmitSoundToAll(g_RocketSound[GetRandomInt(0, sizeof(g_RocketSound) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,80);
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);
	}
	public void PlayKilledEnemySound(int target) 
	{
		int Health = GetEntProp(target, Prop_Data, "m_iHealth");
		
		if(Health <= 0)
		{
			if(target <= MaxClients)
			{
				static Race race;
				Races_GetClientInfo(target, race);
				if(StrEqual(race.Name, "Iberian"))
				{
					switch(GetRandomInt(0,2))
					{
						case 0:
							NpcSpeechBubble(this.index, "Iberians...", 7, {255,0,0,255}, {0.0,0.0,120.0}, "");
						case 1:
							NpcSpeechBubble(this.index, "Here comes payday.", 7, {255,9,9,255}, {0.0,0.0,120.0}, "");
						case 2:
							NpcSpeechBubble(this.index, "Foolish Avians.", 7, {255,9,9,255}, {0.0,0.0,120.0}, "");
					}
					return;
				}
			}

			switch(GetRandomInt(0,2))
			{
				case 0:
					NpcSpeechBubble(this.index, "Not on my hitlist, but regardless.", 7, {255,0,0,255}, {0.0,0.0,120.0}, "");
				case 1:
					NpcSpeechBubble(this.index, "In my way? Extra pay.", 7, {255,9,9,255}, {0.0,0.0,120.0}, "");
				case 2:
					NpcSpeechBubble(this.index, "I wonder how much is put on their head.", 7, {255,9,9,255}, {0.0,0.0,120.0}, "");
			}
			EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);
			this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(5.0, 10.0);
		}
	}
	public void PlayMeleeSound()
 	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);
	}
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);	
	}
	
	property float m_flThrowSupportGrenadeHappening
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flThrowSupportGrenadeHappeningCD
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flJumpCooldown
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property float m_flJumpHappening
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	property float m_flWasAirbornInJump
	{
		public get()							{ return fl_AbilityOrAttack[this.index][4]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][4] = TempValueForProperty; }
	}
	property float m_flKickUpHappening
	{
		public get()							{ return fl_AbilityOrAttack[this.index][5]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][5] = TempValueForProperty; }
	}
	property float m_flKickUpCD
	{
		public get()							{ return fl_AbilityOrAttack[this.index][6]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][6] = TempValueForProperty; }
	}
	property float m_flHitKickDoInstaDash
	{
		public get()							{ return fl_AbilityOrAttack[this.index][7]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][7] = TempValueForProperty; }
	}
	public int FireGrenade(float vecTarget[3])
	{
		int entity = CreateEntityByName("tf_projectile_pipe_remote");
		if(IsValidEntity(entity))
		{
			float vecForward[3], vecSwingStart[3], vecAngles[3];
			this.GetVectors(vecForward, vecSwingStart, vecAngles);
	
			GetAbsOrigin(this.index, vecSwingStart);
			vecSwingStart[2] += 90.0;
	
			MakeVectorFromPoints(vecSwingStart, vecTarget, vecAngles);
			GetVectorAngles(vecAngles, vecAngles);
	
			vecSwingStart[0] += vecForward[0] * 64;
			vecSwingStart[1] += vecForward[1] * 64;
			vecSwingStart[2] += vecForward[2] * 64;
	
			vecForward[0] = Cosine(DegToRad(vecAngles[0]))*Cosine(DegToRad(vecAngles[1]))*800.0;
			vecForward[1] = Cosine(DegToRad(vecAngles[0]))*Sine(DegToRad(vecAngles[1]))*800.0;
			vecForward[2] = Sine(DegToRad(vecAngles[0]))*-800.0;
			
			SetEntProp(entity, Prop_Data, "m_nNextThinkTick", -1);
			SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", this.index);
			SetEntProp(entity, Prop_Send, "m_iType", 1);
			
			SetEntPropFloat(entity, Prop_Send, "m_flDamage", 75.0); 
			f_CustomGrenadeDamage[entity] = 75.0;	
			SetEntProp(entity, Prop_Send, "m_iTeamNum", TFTeam_Blue);
			TeleportEntity(entity, vecSwingStart, vecAngles, NULL_VECTOR);
			DispatchSpawn(entity);
			SetEntityModel(entity, "models/props_lakeside_event/bomb_temp.mdl");
			SetEntPropFloat(entity, Prop_Send, "m_flModelScale", 0.4);
			TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, vecForward);
			b_StickyIsSticking[entity] = true;
			
	//		SetEntProp(entity, Prop_Send, "m_bTouched", true);
			SetEntityCollisionGroup(entity, 1);
			return entity;
		}
		return -1;
	}
	public Whiteflower_Boss(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Whiteflower_Boss npc = view_as<Whiteflower_Boss>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", "300", ally, false,_,_,_,_));

		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");				
		i_NpcWeight[npc.index] = 1;

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		KillFeed_SetKillIcon(npc.index, "sword");

		npc.AddActivityViaSequence("p_jumpuploop");

		npc.m_bisWalking = false;

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_bDissapearOnDeath = false;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;

		f3_SpawnPosition[npc.index][0] = vecPos[0];
		f3_SpawnPosition[npc.index][1] = vecPos[1];
		f3_SpawnPosition[npc.index][2] = vecPos[2];	

		

		func_NPCDeath[npc.index] = Whiteflower_Boss_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Whiteflower_Boss_OnTakeDamage;
		func_NPCThink[npc.index] = Whiteflower_Boss_ClotThink;
		func_NPCDeathForward[npc.index] = Whiteflower_Boss_NPCDeathAlly;
		fl_TotalArmor[npc.index] = 0.35;
		npc.m_flJumpCooldown = GetGameTime() + 10.0;
		npc.m_flThrowSupportGrenadeHappeningCD = GetGameTime() + 15.0;
		
	
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_claymore/c_claymore.mdl");
		SetVariantString("0.8");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 2);

		npc.m_iWearable2 = npc.EquipItem("partyhat", "models/workshop/player/items/medic/robo_medic_blighted_beak/robo_medic_blighted_beak.mdl");
		SetVariantString("1.1");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		npc.m_iWearable3 = npc.EquipItem("partyhat", "models/workshop/player/items/all_class/sbox2014_knight_helmet/sbox2014_knight_helmet_spy.mdl");
		SetVariantString("1.2");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		npc.m_iWearable4 = npc.EquipItem("partyhat", "models/workshop/player/items/demo/hw2013_demo_cape/hw2013_demo_cape.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		
	
		npc.StopPathing();
			
		
		return npc;
	}
	
}


public void Whiteflower_Boss_ClotThink(int iNPC)
{
	Whiteflower_Boss npc = view_as<Whiteflower_Boss>(iNPC);

	float gameTime = GetGameTime(npc.index);

	//some npcs deservere full update time!
	if(npc.m_flNextDelayTime > gameTime)
	{
		return;
	}

	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();	

	if(npc.m_blPlayHurtAnimation && npc.m_flDoingAnimation < gameTime) //Dont play dodge anim if we are in an animation.
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST");
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}

	if(npc.m_flNextThinkTime > gameTime)
	{
		return;
	}
	npc.m_flNextThinkTime = gameTime + 0.1;

	// npc.m_iTarget comes from here, This only handles out of battle instancnes, for inbattle, code it yourself. It also makes NPCS jump if youre too high up.
	Npc_Base_Thinking(iNPC, 500.0, "ACT_RUN", "p_jumpuploop", 0.0, gameTime, _ , true);

	
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			if(IsValidEnemy(npc.index, npc.m_iTarget))
			{
				Handle swingTrace;
				float WorldSpaceCenterVec[3]; 
				WorldSpaceCenter(npc.m_iTarget, WorldSpaceCenterVec);
				npc.FaceTowards(WorldSpaceCenterVec, 15000.0); //Snap to the enemy. make backstabbing hard to do.
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget))
				{
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					float damage = 1550000.0;
					
					if(target > 0) 
					{
						SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB);
						// Hit sound
						npc.PlayMeleeHitSound();
						if(target <= MaxClients)
							Client_Shake(target, 0, 25.0, 25.0, 0.5, false);

						npc.PlayKilledEnemySound(npc.m_iTarget);
					}
				}
				delete swingTrace;
			}
		}
	}
	if(npc.m_flKickUpHappening)
	{
		if(npc.m_flKickUpHappening < gameTime)
		{
			npc.m_flKickUpHappening = 0.0;
			
			float vAngles[3];								
			GetEntPropVector(iNPC, Prop_Data, "m_angRotation", vAngles); 
			vAngles[0] = 0.0;	
			SetEntPropVector(iNPC, Prop_Data, "m_angRotation", vAngles); 
			if(IsValidEnemy(npc.index, npc.m_iTarget))
			{
				Handle swingTrace;
				float WorldSpaceCenterVec[3]; 
				WorldSpaceCenter(npc.m_iTarget, WorldSpaceCenterVec);
				npc.FaceTowards(WorldSpaceCenterVec, 15000.0); //Snap to the enemy. make backstabbing hard to do.
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, .Npc_type = 1))
				{
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					float damage = 1650000.0;
					
					if(target > 0) 
					{
						SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB);
						npc.m_flJumpCooldown = 0.0;
						npc.m_flHitKickDoInstaDash = 1.0;
						// Hit sound
						npc.PlayMeleeHitSound();
						
						if(b_ThisWasAnNpc[target])
							PluginBot_Jump(target, {0.0,0.0,300.0});
						else
							TeleportEntity(target, NULL_VECTOR, NULL_VECTOR, {0.0,0.0,300.0});

						Custom_Knockback(iNPC, target, 400.0, true);
						

						npc.PlayKilledEnemySound(npc.m_iTarget);
					}
				}
				delete swingTrace;
			}
		}
	}
	
	if(npc.m_flJumpHappening)
	{
		if(IsValidEnemy(npc.index, npc.m_iTarget))
		{
			float WorldSpaceCenterVec[3]; 
			WorldSpaceCenter(npc.m_iTarget, WorldSpaceCenterVec);
			npc.FaceTowards(WorldSpaceCenterVec, 15000.0); //Snap to the enemy. make backstabbing hard to do.
		}
		//We want to jump at the enemy the moment we are allowed to!
		if(npc.m_flJumpHappening < gameTime)
		{
			npc.m_flJumpHappening = 0.0;
			if(IsValidEnemy(npc.index, npc.m_iTarget))
			{
				float WorldSpaceCenterVec[3]; 
				float WorldSpaceCenterVecSelf[3]; 
				WorldSpaceCenter(npc.m_iTarget, WorldSpaceCenterVec);
				WorldSpaceCenter(npc.index, WorldSpaceCenterVecSelf);

				float flDistanceToTarget = GetVectorDistance(WorldSpaceCenterVecSelf, WorldSpaceCenterVec);
				float SpeedToPredict = flDistanceToTarget * 2.0;
				if(npc.m_flHitKickDoInstaDash)
				{
					SpeedToPredict *= 0.15;
				}
				PredictSubjectPositionForProjectiles(npc, npc.m_iTarget, SpeedToPredict, _,WorldSpaceCenterVec);
				//da jump!
				npc.m_flDoingAnimation = gameTime + 0.45;
				PluginBot_Jump(npc.index, WorldSpaceCenterVec);
				npc.FaceTowards(WorldSpaceCenterVec, 15000.0); //Snap to the enemy. make backstabbing hard to do.
				npc.m_flWasAirbornInJump = gameTime + 0.5;
				Zero(b_TouchedEnemyTarget);
				EmitCustomToAll("rpg_fortress/enemy/whiteflower_dash.mp3", npc.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, 3.0, 100);
				IgniteTargetEffect(npc.index);
				if(npc.m_iChanged_WalkCycle != 7) 	
				{
					npc.m_bisWalking = false;
					npc.m_iChanged_WalkCycle = 7;
					npc.SetActivity("ACT_JUMP");
					npc.m_flSpeed = 0.0;
					npc.StopPathing();
				}
			}
		}
		return;
	}
	if (!npc.m_flJumpHappening && npc.m_flWasAirbornInJump)
	{
		if(npc.IsOnGround() && npc.m_flWasAirbornInJump < gameTime)
		{
			npc.m_flWasAirbornInJump = 0.0;
			npc.m_flHitKickDoInstaDash = 0.0;
			ExtinguishTarget(npc.index);
		}
		else
		{
			WhiteflowerKickLogic(npc.index);
		}
	}
	WF_ThrowGrenadeHappening(npc);

	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3];
		WorldSpaceCenter(npc.m_iTarget, vecTarget);
		float vecSelf[3];
		WorldSpaceCenter(npc.index, vecSelf);

		float flDistanceToTarget = GetVectorDistance(vecTarget, vecSelf, true);
			
		//Predict their pos.
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3]; 
			PredictSubjectPosition(npc, npc.m_iTarget,_,_,vPredictedPos);
			
			npc.SetGoalVector(vPredictedPos);
		}
		else
		{
			npc.SetGoalEntity(npc.m_iTarget);
		}

		if(npc.m_flDoingAnimation > gameTime) //I am doing an animation or doing something else, default to doing nothing!
		{
			npc.m_iState = -1;
		}
		else if (npc.m_flJumpCooldown < gameTime)
		{
			//We jump, no matter if far or close, see state to see more logic.
			//we melee them!
			npc.m_iState = 3; //enemy is abit further away.
		}
		else if(b_thisNpcIsABoss[npc.index] && flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 8.0) && npc.m_flThrowSupportGrenadeHappeningCD < gameTime)
		{
			npc.m_iState = 2;
		}
		else if(b_thisNpcIsABoss[npc.index] && flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 0.65) && npc.m_flKickUpCD < gameTime)
		{
			npc.m_iState = 4; //Engage in Close Range Destruction.
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
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity("ACT_RUN");
					npc.m_flSpeed = 380.0;
					view_as<CClotBody>(iNPC).StartPathing();
				}
			}
			case 1:
			{			
				//Walk to target
				if(!npc.m_bPathing)
					npc.StartPathing();
					
				if(npc.m_iChanged_WalkCycle != 4) 	
				{
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity("ACT_RUN");
					npc.m_flSpeed = 380.0;
					view_as<CClotBody>(iNPC).StartPathing();
				}
				int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				//Can i see This enemy, is something in the way of us?
				//Dont even check if its the same enemy, just engage in killing, and also set our new target to this just in case.
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.m_iTarget = Enemy_I_See;

					npc.AddGesture("ACT_MELEE_ATTACK_SWING_GESTURE", _,_,_,1.0);

					npc.PlayMeleeSound();
					
					npc.m_flAttackHappens = gameTime + 0.35;
					npc.m_flDoingAnimation = gameTime + 0.35;
					npc.m_flNextMeleeAttack = gameTime + 0.65;
				}
			}
			case 4:
			{			
				//Walk to target
				if(!npc.m_bPathing)
					npc.StartPathing();
					
				if(npc.m_iChanged_WalkCycle != 4) 	
				{
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity("ACT_RUN");
					npc.m_flSpeed = 380.0;
					view_as<CClotBody>(iNPC).StartPathing();
				}
				int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				//Can i see This enemy, is something in the way of us?
				//Dont even check if its the same enemy, just engage in killing, and also set our new target to this just in case.
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.m_iTarget = Enemy_I_See;


					npc.PlayMeleeSound();
					
					npc.m_flKickUpHappening = gameTime + 0.1;
					npc.m_flDoingAnimation = gameTime + 0.35;
					npc.m_flKickUpCD = gameTime + 4.0;
					if(npc.m_iChanged_WalkCycle != 8) 	
					{
						float vAngles[3];								
						GetEntPropVector(iNPC, Prop_Data, "m_angRotation", vAngles); 
						vAngles[0] = -45.0;	
						SetEntPropVector(iNPC, Prop_Data, "m_angRotation", vAngles); 
						npc.m_iChanged_WalkCycle = 8;
						npc.m_flSpeed = 0.0;
						npc.StopPathing();
						
						npc.m_bisWalking = false;
						npc.AddActivityViaSequence("kickdoorbaton");
						npc.SetCycle(0.30);
						npc.SetPlaybackRate(2.0);
					}
				}
			}
			case 2:
			{			
				//Walk to target
				if(!npc.m_bPathing)
					npc.StartPathing();
					
				int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				//Can i see This enemy, is something in the way of us?
				//Dont even check if its the same enemy, just engage in killing, and also set our new target to this just in case.
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					if(npc.m_iChanged_WalkCycle != 5) 	
					{
						npc.m_bisWalking = false;
						npc.m_iChanged_WalkCycle = 5;
						npc.SetActivity("ACT_RANGE_ATTACK_THROW");
						npc.SetPlaybackRate(1.5);
						npc.StopPathing();
							
					}
					npc.m_flAttackHappens = 0.0;
					npc.m_flDoingAnimation = gameTime + 1.0;
					npc.m_flNextMeleeAttack = gameTime + 0.65;
					npc.m_flThrowSupportGrenadeHappeningCD = gameTime + 25.0;
					npc.m_flThrowSupportGrenadeHappening = gameTime + 1.0;
				}
			}
			case 3:
			{		
				//Jump at enemy	
				int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.m_iTarget = Enemy_I_See;

					npc.m_flAttackHappens = gameTime + 0.5;
					npc.m_flDoingAnimation = gameTime + 0.5;
					npc.m_flNextMeleeAttack = 0.0;
					npc.m_flJumpCooldown = gameTime + 5.0;
					if(!b_thisNpcIsABoss[npc.index])
						npc.m_flJumpCooldown = gameTime + 8.0;

					if(npc.m_iOverlordComboAttack == 1)
					{
						npc.m_flJumpCooldown = gameTime + 4.0;
					}
					//if enemy 
					npc.PlayRocketSound();
					if(b_thisNpcIsABoss[npc.index])
					{
						for(float loopDo = 1.0; loopDo <= 2.0; loopDo += 0.5)
						{
							float vecSelf2[3];
							WorldSpaceCenter(npc.index, vecSelf2);
							vecSelf2[2] += 50.0;
							vecSelf2[0] += GetRandomFloat(-10.0, 10.0);
							vecSelf2[1] += GetRandomFloat(-10.0, 10.0);
							float RocketDamage = 2000000.0;
							int RocketGet = npc.FireRocket(vecSelf2, RocketDamage, 200.0);
							DataPack pack;
							CreateDataTimer(loopDo, WhiteflowerTank_Rocket_Stand, pack, TIMER_FLAG_NO_MAPCHANGE);
							pack.WriteCell(EntIndexToEntRef(RocketGet));
							pack.WriteCell(EntIndexToEntRef(npc.m_iTarget));
						}
					}
					/*
					if(flDistanceToTarget > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 3.0))
					*/
					{
						//enemy is indeed to far away, jump at them
						if(!npc.m_flHitKickDoInstaDash)
							npc.m_flJumpHappening = gameTime + 0.25;
						else
							npc.m_flJumpHappening = 1.0;

						float flPos[3];
						GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flPos);
						flPos[2] += 70.0;
						int particler = ParticleEffectAt(flPos, "scout_dodge_blue", 1.0);
						SetParent(npc.index, particler);
						if(npc.m_iChanged_WalkCycle != 6) 	
						{
							npc.m_bisWalking = false;
							npc.m_iChanged_WalkCycle = 6;
							npc.AddActivityViaSequence("citizen4_preaction");
							npc.SetPlaybackRate(0.0);
							npc.m_flSpeed = 0.0;
							npc.StopPathing();
						}
					}
				}
			}
		}
	}
	npc.PlayIdleSound();
}


public Action Whiteflower_Boss_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;

	Whiteflower_Boss npc = view_as<Whiteflower_Boss>(victim);

	float gameTime = GetGameTime(npc.index);

	if (npc.m_flHeadshotCooldown < gameTime)
	{
		npc.m_flHeadshotCooldown = gameTime + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	return Plugin_Changed;
}

public void Whiteflower_Boss_NPCDeath(int entity)
{
	Whiteflower_Boss npc = view_as<Whiteflower_Boss>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();
	}
	if(b_thisNpcIsABoss[npc.index])
	{
		float AllyPos[3];
		float SelfPos[3];
		float flDistanceToTarget;
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", SelfPos);
		for(int client = 1; client <= MaxClients; client++)
		{
			if(IsValidClient(client) && Dungeon_IsDungeon(client))
			{
				GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", AllyPos);
				flDistanceToTarget = GetVectorDistance(SelfPos, AllyPos, true);
				if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 24.0))
				{
					CPrintToChat(client, "{crimson}Whiteflower{default}: I'll be back... even if i have to it... alone...");	
					CPrintToChat(client, "Whiteflower Escapes.");	
				}
			}
		}
	}
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
}



void WF_ThrowGrenadeHappening(Whiteflower_Boss npc)
{
	if(npc.m_flThrowSupportGrenadeHappening)
	{
		if(npc.m_flThrowSupportGrenadeHappening < GetGameTime())
		{
			npc.m_flThrowSupportGrenadeHappening = 0.0;
			float vecTarget[3];
			float VecStart[3]; WorldSpaceCenter(npc.index, VecStart );

			if(IsValidEnemy(npc.index, npc.m_iTarget))
			{
				PredictSubjectPositionForProjectiles(npc, npc.index, 800.0,_,vecTarget);
			}
			else
			{
				WorldSpaceCenter(npc.index, vecTarget);
				//incase theres no valid enemy, throw onto ourselves instead.
			}
			//damage doesnt matter.
			int Grenade = npc.FireGrenade(vecTarget);
			float GrenadeRangeSupport = 600.0;
			float GrenadeRangeDamage = 0.0;
			float HealDo = 2500000.0;
			WF_GrenadeSupportDo(npc.index, Grenade, GrenadeRangeDamage, GrenadeRangeSupport, HealDo);
			float SpeedReturn[3];
			ArcToLocationViaSpeedProjectile(VecStart, vecTarget, SpeedReturn, 1.75, 1.0);
			TeleportEntity(Grenade, NULL_VECTOR, NULL_VECTOR, SpeedReturn);
			//Throw a grenade towards the target!
		}
	}
}

void WF_GrenadeSupportDo(int entity, int grenade, float damage, float RangeSupport, float HealDo)
{
	DataPack pack;
	CreateDataTimer(3.0, Timer_WF_SupportGrenade, pack, TIMER_REPEAT);
	pack.WriteCell(EntIndexToEntRef(entity));
	pack.WriteCell(EntIndexToEntRef(grenade));
	pack.WriteFloat(damage);
	pack.WriteFloat(RangeSupport);
	pack.WriteFloat(HealDo);

	
	DataPack pack2;
	CreateDataTimer(0.25, Timer_WF_SupportGrenadeIndication, pack2, TIMER_REPEAT);
	pack2.WriteCell(EntIndexToEntRef(entity));
	pack2.WriteCell(EntIndexToEntRef(grenade));
	pack2.WriteFloat(damage);
	pack2.WriteFloat(RangeSupport);
}

public Action Timer_WF_SupportGrenadeIndication(Handle timer, DataPack pack)
{
	pack.Reset();
	int OwnerNpc = EntRefToEntIndex(pack.ReadCell());
	int Projectile = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidEntity(OwnerNpc))
	{
		if(IsValidEntity(Projectile))
		{
			//Cancel.
			RemoveEntity(Projectile);
		}
		return Plugin_Stop;
	}
	else
	{
		if(!IsEntityAlive(OwnerNpc))
		{
			if(IsValidEntity(Projectile))
			{
				//Cancel.
				RemoveEntity(Projectile);
			}
			return Plugin_Stop;
		}
	}	
	if(!IsValidEntity(Projectile))
		return Plugin_Stop;
		
	float DamageDeal = pack.ReadFloat();
	float RangeSupport = pack.ReadFloat();
	float RangeSupport2 = RangeSupport * 0.25; 
	

	float pos[3]; GetEntPropVector(Projectile, Prop_Data, "m_vecAbsOrigin", pos);
	pos[2] += 5.0;
	if(DamageDeal >= 1.0)
	{
		spawnRing_Vectors(pos, RangeSupport * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 0, 0, 200, 1, 0.3, 2.0, 2.0, 2);
		spawnRing_Vectors(pos, RangeSupport2 * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 0, 0, 200, 1, 0.3, 2.0, 2.0, 2);
	}
	else
	{
		spawnRing_Vectors(pos, RangeSupport * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 0, 255, 0, 200, 1, 0.3, 2.0, 2.0, 2);
		spawnRing_Vectors(pos, RangeSupport2 * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 0, 255, 0, 200, 1, 0.3, 2.0, 2.0, 2);
	}
	return Plugin_Continue;
}

public Action Timer_WF_SupportGrenade(Handle timer, DataPack pack)
{
	pack.Reset();
	int OwnerNpc = EntRefToEntIndex(pack.ReadCell());
	int Projectile = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidEntity(OwnerNpc))
	{
		if(IsValidEntity(Projectile))
		{
			//Cancel.
			RemoveEntity(Projectile);
		}
		return Plugin_Stop;
	}
	else
	{
		if(!IsEntityAlive(OwnerNpc))
		{
			if(IsValidEntity(Projectile))
			{
				//Cancel.
				RemoveEntity(Projectile);
			}
			return Plugin_Stop;
		}
	}
	
	if(!IsValidEntity(Projectile))
		return Plugin_Stop;
		
	float DamageDeal = pack.ReadFloat();
	float RangeSupport = pack.ReadFloat();
	float HealDo = pack.ReadFloat();

	if(DamageDeal >= 1.0)
	{
		float pos[3]; GetEntPropVector(Projectile, Prop_Data, "m_vecAbsOrigin", pos);
		pos[2] += 5.0;

		spawnRing_Vectors(pos, 2.0 /*startin range*/, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 0, 0, 200, 1, 0.5, 2.0, 2.0, 2, RangeSupport * 2.0);
		Explode_Logic_Custom(DamageDeal , OwnerNpc , OwnerNpc , -1 , pos , RangeSupport);	//acts like a rocket
	}
	if(HealDo >= 1.0)
	{
		ExpidonsaGroupHeal(Projectile, RangeSupport, 99, HealDo, 1.0, false);
		RPGDoHealEffect(Projectile, RangeSupport);
	}
	return Plugin_Continue;

}



public void Whiteflower_Boss_NPCDeathAlly(int self, int ally)
{
	
	if(GetTeam(ally) != GetTeam(self))
	{
		return;
	}
	/*
	if(i_NpcInternalId[ally] == NPCId)
	{
		return;
	}
	*/
	float AllyPos[3];
	GetEntPropVector(ally, Prop_Data, "m_vecAbsOrigin", AllyPos);
	float SelfPos[3];
	GetEntPropVector(self, Prop_Data, "m_vecAbsOrigin", SelfPos);
	float flDistanceToTarget = GetVectorDistance(SelfPos, AllyPos, true);
	//This means its WELL out of their range.
	
	if(flDistanceToTarget > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 24.0))
		return;
	
	if(!b_NpcIsInADungeon[ally])
	{
		//This enemy only appears in a dungeon anyways.
		return;
	}
	int speech = GetRandomInt(1,4);
	Whiteflower_Boss npc = view_as<Whiteflower_Boss>(self);
	if(npc.m_iOverlordComboAttack == 1)
	{
		for(int client = 1; client <= MaxClients; client++)
		{
			if(IsValidClient(client) && Dungeon_IsDungeon(client))
			{
				GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", AllyPos);
				flDistanceToTarget = GetVectorDistance(SelfPos, AllyPos, true);
				if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 24.0))
				{
					switch(speech)
					{
						case 1:
						{
							CPrintToChat(client,"{crimson}Whiteflower{default}: I dont care, i will avange them.");	
						}
						case 2:
						{
							CPrintToChat(client,"{crimson}Whiteflower{default}: You will follow them.");	
						}
						case 3:
						{
							CPrintToChat(client,"{crimson}Whiteflower{default}: Whatever did they do huh.");	
						}
						case 4:
						{
							CPrintToChat(client,"{crimson}Whiteflower{default}: Im the bad guy? you are.");	
						}
					}
				}
			}
		}
		return;
	}
	fl_TotalArmor[self] = fl_TotalArmor[self] * 1.1;
	if(fl_TotalArmor[self] >= 1.0)
	{
		fl_TotalArmor[self] = 1.0;
	}
	fl_Extra_Damage[self] = fl_Extra_Damage[self] * 0.99;
	if(fl_Extra_Damage[self] <= 0.9)
	{
		fl_Extra_Damage[self] = 0.9;
	}

	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsValidClient(client) && Dungeon_IsDungeon(client))
		{
			GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", AllyPos);
			flDistanceToTarget = GetVectorDistance(SelfPos, AllyPos, true);
			if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 24.0))
			{
				
				switch(speech)
				{
					case 1:
					{
						CPrintToChat(client,"{crimson}Whiteflower{default}: How dare you kill my army... \n*He weakens.*");	
					}
					case 2:
					{
						CPrintToChat(client,"{crimson}Whiteflower{default}: You are NOTHING!\n*He weakens.*");	
					}
					case 3:
					{
						CPrintToChat(client,"{crimson}Whiteflower{default}: You and bob and all are in my way!\n*He weakens.*");	
					}
					case 4:
					{
						CPrintToChat(client,"{crimson}Whiteflower{default}: Im going to kill you.\n*He weakens.*");	
					}
				}
			}
		}
	}
}


static void Whiteflower_KickTouched(int entity, int enemy)
{
	if(!IsValidEnemy(entity, enemy))
		return;

	if(b_TouchedEnemyTarget[enemy])
		return;

	Whiteflower_Boss npc = view_as<Whiteflower_Boss>(entity);
	b_TouchedEnemyTarget[enemy] = true;
	
	float targPos[3];
	WorldSpaceCenter(enemy, targPos);
	SDKHooks_TakeDamage(enemy, entity, entity, 2500000.0, DMG_CLUB, -1, NULL_VECTOR, targPos);
	ParticleEffectAt(targPos, "skull_island_embers", 2.0);
	npc.DispatchParticleEffect(npc.index, "mvm_soldier_shockwave", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("head"), PATTACH_POINT_FOLLOW, true);
	EmitSoundToAll("plats/tram_hit4.wav", entity, SNDCHAN_STATIC, 80, _, 0.8);
	EmitSoundToAll("plats/tram_hit4.wav", entity, SNDCHAN_STATIC, 80, _, 0.8);
	EmitSoundToAll("plats/tram_hit4.wav", entity, SNDCHAN_STATIC, 80, _, 0.8);

	if(enemy <= MaxClients)
	{
		f_AntiStuckPhaseThrough[enemy] = GetGameTime() + 1.0;
		ApplyStatusEffect(enemy, enemy, "Intangible", 1.0);
		Custom_Knockback(entity, enemy, 1500.0, true, true);
		TF2_AddCondition(enemy, TFCond_LostFooting, 0.5);
		TF2_AddCondition(enemy, TFCond_AirCurrent, 0.5);
	}
}

void WhiteflowerKickLogic(int iNPC)
{
	CClotBody npc = view_as<CClotBody>(iNPC);
	static float vel[3];
	static float flMyPos[3];
	npc.GetVelocity(vel);
	GetEntPropVector(iNPC, Prop_Data, "m_vecAbsOrigin", flMyPos);
		
	if(b_IsGiant[iNPC])
	{
		hullcheckmaxs = view_as<float>( { 30.0, 30.0, 120.0 } );
		hullcheckmins = view_as<float>( { -30.0, -30.0, 0.0 } );	
	}
	else if(f3_CustomMinMaxBoundingBox[iNPC][1] != 0.0)
	{
		hullcheckmaxs[0] = f3_CustomMinMaxBoundingBox[iNPC][0];
		hullcheckmaxs[1] = f3_CustomMinMaxBoundingBox[iNPC][1];
		hullcheckmaxs[2] = f3_CustomMinMaxBoundingBox[iNPC][2];

		hullcheckmins[0] = -f3_CustomMinMaxBoundingBox[iNPC][0];
		hullcheckmins[1] = -f3_CustomMinMaxBoundingBox[iNPC][1];
		hullcheckmins[2] = 0.0;	
	}
	else
	{
		hullcheckmaxs = view_as<float>( { 24.0, 24.0, 82.0 } );
		hullcheckmins = view_as<float>( { -24.0, -24.0, 0.0 } );			
	}
	
	static float flPosEnd[3];
	flPosEnd = flMyPos;
	ScaleVector(vel, 0.1);
	AddVectors(flMyPos, vel, flPosEnd);
	
	ResetTouchedentityResolve();
	ResolvePlayerCollisions_Npc_Internal(flMyPos, flPosEnd, hullcheckmins, hullcheckmaxs, iNPC);

	for (int entity_traced = 0; entity_traced < MAXENTITIES; entity_traced++)
	{
		if(!TouchedNpcResolve(entity_traced))
			break;

		if(i_IsABuilding[ConvertTouchedResolve(entity_traced)])
			continue;
		
		Whiteflower_KickTouched(iNPC,ConvertTouchedResolve(entity_traced));
	}
	ResetTouchedentityResolve();
}