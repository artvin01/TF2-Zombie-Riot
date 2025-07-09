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
	"weapons/physcannon/energy_sing_explosion2.wav",
};
static char g_RocketSound[][] = {
	"weapons/rpg/rocketfire1.wav",
};
static const char g_HealSound[][] = {
	"items/medshot4.wav",
};
static char g_TeleportSound[][] = {
	"plats/elevator_stop.wav",
};
static char g_LaserSound[][] = {
	"weapons/physcannon/superphys_launch1.wav",
	"weapons/physcannon/superphys_launch2.wav",
	"weapons/physcannon/superphys_launch3.wav",
	"weapons/physcannon/superphys_launch4.wav",
};


public void Whiteflower_OutlanderLeader_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_TeleportSound));	i++) { PrecacheSound(g_TeleportSound[i]);	}
	for (int i = 0; i < (sizeof(g_IdleSound));	i++) { PrecacheSound(g_IdleSound[i]);	}
	for (int i = 0; i < (sizeof(g_HurtSound));	i++) { PrecacheSound(g_HurtSound[i]);	}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds));	i++) { PrecacheSound(g_IdleAlertedSounds[i]);	}
	for (int i = 0; i < (sizeof(g_RangedAttackSoundsSecondary));	i++) { PrecacheSound(g_RangedAttackSoundsSecondary[i]);	}
	for (int i = 0; i < (sizeof(g_RocketSound));	i++) { PrecacheSound(g_RocketSound[i]);	}
	for (int i = 0; i < (sizeof(g_HealSound)); i++) { PrecacheSound(g_HealSound[i]); }
	for (int i = 0; i < (sizeof(g_TeleportSound)); i++) { PrecacheSound(g_TeleportSound[i]); }
	for (int i = 0; i < (sizeof(g_LaserSound)); i++) { PrecacheSound(g_LaserSound[i]); }
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "W.F. Outlander Leader");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_whiteflower_outlander_leader");
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Whiteflower_OutlanderLeader(vecPos, vecAng, team);
}

methodmap Whiteflower_OutlanderLeader < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;

		EmitSoundToAll(g_IdleSound[GetRandomInt(0, sizeof(g_IdleSound) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);

		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
	}
	property float m_flEnrageTele
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	
	public void PlayHurtSound()
	{
		
		EmitSoundToAll(g_HurtSound[GetRandomInt(0, sizeof(g_HurtSound) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);
	}
	public void PlayRangedAttackSecondarySound() {
		EmitSoundToAll(g_RangedAttackSoundsSecondary[GetRandomInt(0, sizeof(g_RangedAttackSoundsSecondary) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		

	}
	public void PlayHealSound() 
	{
		EmitSoundToAll(g_HealSound[GetRandomInt(0, sizeof(g_HealSound) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME - 0.1, 110);

	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);
	}
	public void PlayKilledEnemySound(int target) 
	{
		if(!IsValidEntity(target))
			return;

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
							NpcSpeechBubble(this.index, "Would have hoped you were Irene.", 7, {255,0,0,255}, {0.0,0.0,120.0}, "");
						case 1:
							NpcSpeechBubble(this.index, "Why do these birds still try?", 7, {255,9,9,255}, {0.0,0.0,120.0}, "");
						case 2:
							NpcSpeechBubble(this.index, "Hey, i was told iberians are too scared.", 7, {255,9,9,255}, {0.0,0.0,120.0}, "");
					}
					return;
				}
			}

			switch(GetRandomInt(0,2))
			{
				case 0:
					NpcSpeechBubble(this.index, "Threat cleaners, how did that one get through?", 7, {255,0,0,255}, {0.0,0.0,120.0}, "");
				case 1:
					NpcSpeechBubble(this.index, "Thanks for the warmup.", 7, {255,9,9,255}, {0.0,0.0,120.0}, "");
				case 2:
					NpcSpeechBubble(this.index, "Cease to exist.", 7, {255,9,9,255}, {0.0,0.0,120.0}, "");
			}
			EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);
			this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(5.0, 10.0);
		}
	}
	public void PlayMeleeSound()
 	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);
	}
	public void PlayRocketSound()
 	{
		EmitSoundToAll(g_RocketSound[GetRandomInt(0, sizeof(g_RocketSound) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,80);
	}
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);	
	}
	public void PlayTeleportSound()
	{
		EmitSoundToAll(g_TeleportSound[GetRandomInt(0, sizeof(g_TeleportSound) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,110);	
	}
	public void PlayLaserSound()
	{
		EmitSoundToAll(g_LaserSound[GetRandomInt(0, sizeof(g_LaserSound) - 1)], this.index, SNDCHAN_WEAPON, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,120);	
	}
	
	property float m_flSpawnTempClone
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flCloneRageCD
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flCloneRageInit
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property float m_flCloneRageDo
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	public Whiteflower_OutlanderLeader(float vecPos[3], float vecAng[3], int ally)
	{
		Whiteflower_OutlanderLeader npc = view_as<Whiteflower_OutlanderLeader>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", "300", ally, false,_,_,_,_));

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
		

		func_NPCDeath[npc.index] = Whiteflower_OutlanderLeader_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Whiteflower_OutlanderLeader_OnTakeDamage;
		func_NPCThink[npc.index] = Whiteflower_OutlanderLeader_ClotThink;
		
	
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_claymore/c_claymore.mdl");
		SetVariantString("0.8");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 2);

		npc.m_iWearable2 = npc.EquipItem("partyhat", "models/player/items/sniper/hwn_sniper_hat.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
	
		npc.StopPathing();
			
		
		return npc;
	}
	
}

public void Whiteflower_OutlanderLeader_ClotThink(int iNPC)
{
	Whiteflower_OutlanderLeader npc = view_as<Whiteflower_OutlanderLeader>(iNPC);

	float gameTime = GetGameTime(npc.index);

	//some npcs deservere full update time!
	if(npc.m_flNextDelayTime > gameTime)
	{
		return;
	}

	npc.PlayKilledEnemySound(npc.m_iTarget);
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

	if(npc.m_flCloneRageInit)
	{
		ResolvePlayerCollisions_Npc(iNPC, /*damage crush*/ 600000.0);
		if(npc.m_flCloneRageInit < gameTime)
		{
			//Enrage and keep teleporting
			npc.m_flCloneRageDo = gameTime + 2.0;
			npc.m_flCloneRageInit = 0.0;
			npc.SetPlaybackRate(0.0);	
		}
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
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget) )
				{
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					float damage = 850000.0;

					
					if(target > 0) 
					{
						SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB);
						// Hit sound
						npc.PlayMeleeHitSound();

					}
				}
				delete swingTrace;
			}
		}
	}
	
	
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
		//Get position for just travel here.

		if(npc.m_flDoingAnimation > gameTime) //I am doing an animation or doing something else, default to doing nothing!
		{
			npc.m_iState = -1;
		}
		else if (npc.m_flSpawnTempClone < gameTime || npc.m_flCloneRageDo)
		{
			//try to teleport
			npc.m_iState = 2; //enemy is abit further away.
		}
		else if (npc.m_flCloneRageCD < gameTime)
		{
			//try to teleport
			npc.m_iState = 3; //enemy is abit further away.
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
					npc.m_flSpeed = 350.0;
					view_as<CClotBody>(iNPC).StartPathing();
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

					npc.AddGesture("ACT_MELEE_ATTACK_SWING_GESTURE", _,_,_,1.2);

					npc.PlayMeleeSound();
					
					npc.m_flAttackHappens = gameTime + 0.3;
					npc.m_flDoingAnimation = gameTime + 0.3;
					npc.m_flNextMeleeAttack = gameTime + 0.6;
				}
			}
			case 2:
			{		
				if(npc.m_flCloneRageDo)
				{
					//In ragemode we want different logic.
					if(npc.m_flSpawnTempClone > gameTime)
					{
						return;
					}
					if(npc.m_flCloneRageDo < gameTime)
					{
						npc.m_flCloneRageDo = 0.0;
						//end.
						
						if(npc.m_iChanged_WalkCycle != 4) 	
						{
							npc.m_bisWalking = true;
							npc.m_iChanged_WalkCycle = 4;
							npc.SetActivity("ACT_RUN");
							npc.m_flSpeed = 350.0;
							view_as<CClotBody>(iNPC).StartPathing();
						}
						return;
					}
				}
				int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					
					float vPredictedPos[3];
					PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
					vPredictedPos = GetBehindTarget(npc.m_iTarget, 30.0 ,vPredictedPos);
					static float hullcheckmaxs[3];
					static float hullcheckmins[3];
					hullcheckmaxs = view_as<float>( { 24.0, 24.0, 82.0 } );
					hullcheckmins = view_as<float>( { -24.0, -24.0, 0.0 } );	

					float PreviousPos[3];
					WorldSpaceCenter(npc.index, PreviousPos);
					
					bool Succeed = Npc_Teleport_Safe(npc.index, vPredictedPos, hullcheckmins, hullcheckmaxs, true);
					if(Succeed)
					{
						npc.PlayTeleportSound();
						float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
						float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
						
						float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
						TE_Particle("pyro_blast", PreviousPos, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
						TE_Particle("pyro_blast_lines", PreviousPos, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
						TE_Particle("pyro_blast_warp", PreviousPos, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
						TE_Particle("pyro_blast_flash", PreviousPos, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
						float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
						npc.FaceTowards(VecEnemy, 15000.0);
						npc.m_flSpawnTempClone = GetGameTime(npc.index) + 5.5;

						if(npc.m_flCloneRageDo)
							npc.m_flSpawnTempClone = GetGameTime(npc.index) + 0.3;

						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.7; //so they cant instastab you!
						vPredictedPos[2] += 45.0;
						WF_Outlander_LeaderInitiateLaserAttack(npc.index, VecEnemy, PreviousPos);
						WF_Outlander_LeaderInitiateLaserAttack(npc.index, WorldSpaceVec, PreviousPos);
					}
					else
					{
						if(!npc.m_flCloneRageDo)
							npc.m_flSpawnTempClone = GetGameTime(npc.index) + 1.0; //Retry in a second
					}
				}
			}
			case 3:
			{
				if(npc.m_iChanged_WalkCycle != 9)
				{
					npc.m_bisWalking = false;
					npc.m_iChanged_WalkCycle = 9;
					npc.AddActivityViaSequence("Stand_to_crouch");
					npc.SetPlaybackRate(0.75);	
					npc.StopPathing();
					
				}
				npc.m_flCloneRageInit = gameTime + 1.35;
				npc.m_flCloneRageCD = gameTime + 15.0;
				npc.m_flSpawnTempClone = 0.0;
			}
		}
	}
	npc.PlayIdleSound();
}


public Action Whiteflower_OutlanderLeader_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;

	Whiteflower_OutlanderLeader npc = view_as<Whiteflower_OutlanderLeader>(victim);

	float gameTime = GetGameTime(npc.index);

	if (npc.m_flHeadshotCooldown < gameTime)
	{
		npc.m_flHeadshotCooldown = gameTime + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	return Plugin_Changed;
}

public void Whiteflower_OutlanderLeader_NPCDeath(int entity)
{
	Whiteflower_OutlanderLeader npc = view_as<Whiteflower_OutlanderLeader>(entity);
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
}


//copied code.

void WF_Outlander_LeaderInitiateLaserAttack(int entity, float VectorTarget[3], float VectorStart[3])
{

	float vecForward[3], vecRight[3], Angles[3];

	MakeVectorFromPoints(VectorStart, VectorTarget, vecForward);
	GetVectorAngles(vecForward, Angles);
	GetAngleVectors(vecForward, vecForward, vecRight, VectorTarget);

	Handle trace = TR_TraceRayFilterEx(VectorStart, Angles, 11, RayType_Infinite, WF_Outlander_Leader_TraceWallsOnly);
	if (TR_DidHit(trace))
	{
		TR_GetEndPosition(VectorTarget, trace);
		
		float lineReduce = 10.0 * 2.0 / 3.0;
		float curDist = GetVectorDistance(VectorStart, VectorTarget, false);
		if (curDist > lineReduce)
		{
			ConformLineDistance(VectorTarget, VectorStart, VectorTarget, curDist - lineReduce);
		}
	}
	delete trace;

	int red = 200;
	int green = 200;
	int blue = 255;
	int colorLayer4[4];
	float diameter = float(10 * 4);
	SetColorRGBA(colorLayer4, red, green, blue, 150);
	//we set colours of the differnet laser effects to give it more of an effect
	int colorLayer1[4];
	SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, 100);
	TE_SetupBeamPoints(VectorStart, VectorTarget, Shared_BEAM_Laser, 0, 0, 0, 0.6, ClampBeamWidth(diameter * 0.1), ClampBeamWidth(diameter * 0.3), 0, 5.0, colorLayer1, 3);
	TE_SendToAll(0.0);

	int glowColor[4];
	SetColorRGBA(glowColor, red, green, blue, 100);
	TE_SetupBeamPoints(VectorStart, VectorTarget, Shared_BEAM_Glow, 0, 0, 0, 0.7, ClampBeamWidth(diameter * 0.1), ClampBeamWidth(diameter * 0.1), 0, 0.5, glowColor, 0);
	TE_SendToAll(0.0);

	DataPack pack = new DataPack();
	pack.WriteCell(EntIndexToEntRef(entity));
	pack.WriteFloat(VectorTarget[0]);
	pack.WriteFloat(VectorTarget[1]);
	pack.WriteFloat(VectorTarget[2]);
	pack.WriteFloat(VectorStart[0]);
	pack.WriteFloat(VectorStart[1]);
	pack.WriteFloat(VectorStart[2]);
	RequestFrames(WF_Outlander_LeaderInitiateLaserAttack_DamagePart, 40, pack);
}

void WF_Outlander_LeaderInitiateLaserAttack_DamagePart(DataPack pack)
{
	for (int i = 1; i < MAXENTITIES; i++)
	{
		LaserVarious_HitDetection[i] = false;
	}
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidEntity(entity))
		entity = 0;

	Whiteflower_OutlanderLeader npc = view_as<Whiteflower_OutlanderLeader>(entity);
	npc.PlayLaserSound();


	float VectorTarget[3];
	float VectorStart[3];
	VectorTarget[0] = pack.ReadFloat();
	VectorTarget[1] = pack.ReadFloat();
	VectorTarget[2] = pack.ReadFloat();
	VectorStart[0] = pack.ReadFloat();
	VectorStart[1] = pack.ReadFloat();
	VectorStart[2] = pack.ReadFloat();

	int red = 255;
	int green = 255;
	int blue = 255;
	int colorLayer4[4];
	float diameter = 30.0;
	SetColorRGBA(colorLayer4, red, green, blue, 100);
	//we set colours of the differnet laser effects to give it more of an effect
	int colorLayer1[4];
	SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, 100);
	TE_SetupBeamPoints(VectorStart, VectorTarget, Shared_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.2), ClampBeamWidth(diameter * 0.35), 0, 5.0, colorLayer1, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(VectorStart, VectorTarget, Shared_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.2), ClampBeamWidth(diameter * 0.25), 0, 5.0, colorLayer1, 3);
	TE_SendToAll(0.0);

	float hullMin[3];
	float hullMax[3];
	hullMin[0] = -float(10);
	hullMin[1] = hullMin[0];
	hullMin[2] = hullMin[0];
	hullMax[0] = -hullMin[0];
	hullMax[1] = -hullMin[1];
	hullMax[2] = -hullMin[2];

	Handle trace;
	trace = TR_TraceHullFilterEx(VectorStart, VectorTarget, hullMin, hullMax, 1073741824, WF_Outlander_Leader_BEAM_TraceUsers, entity);	// 1073741824 is CONTENTS_LADDER?
	delete trace;
			
		
	float CloseDamage = 800000.0;
	float FarDamage = 850000.0;
	float MaxDistance = 1000.0;
	float playerPos[3];
	for (int victim = 1; victim < MAXENTITIES; victim++)
	{
		if (LaserVarious_HitDetection[victim] && GetTeam(entity) != GetTeam(victim))
		{
			GetEntPropVector(victim, Prop_Send, "m_vecOrigin", playerPos, 0);
			float distance = GetVectorDistance(VectorStart, playerPos, false);
			float damage = CloseDamage + (FarDamage-CloseDamage) * (distance/MaxDistance);
			if (damage < 0)
				damage *= -1.0;

			SDKHooks_TakeDamage(victim, entity, entity, damage, DMG_PLASMA, -1, NULL_VECTOR, playerPos);	// 2048 is DMG_NOGIB?
				
		}
	}
	delete pack;
}


public bool WF_Outlander_Leader_BEAM_TraceUsers(int entity, int contentsMask, int client)
{
	if (IsEntityAlive(entity))
	{
		LaserVarious_HitDetection[entity] = true;
	}
	return false;
}

public bool WF_Outlander_Leader_TraceWallsOnly(int entity, int contentsMask)
{
	return !entity;
}