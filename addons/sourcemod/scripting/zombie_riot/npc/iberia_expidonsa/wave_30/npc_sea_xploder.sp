#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/mvm/norm/demoman_mvm_paincrticialdeath01.mp3",
	"vo/mvm/norm/demoman_mvm_paincrticialdeath02.mp3",
	"vo/mvm/norm/demoman_mvm_paincrticialdeath03.mp3",
	"vo/mvm/norm/demoman_mvm_paincrticialdeath04.mp3",
	"vo/mvm/norm/demoman_mvm_paincrticialdeath05.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/mvm/norm/demoman_mvm_painsharp01.mp3",
	"vo/mvm/norm/demoman_mvm_painsharp02.mp3",
	"vo/mvm/norm/demoman_mvm_painsharp03.mp3",
	"vo/mvm/norm/demoman_mvm_painsharp04.mp3",
	"vo/mvm/norm/demoman_mvm_painsharp05.mp3",
	"vo/mvm/norm/demoman_mvm_painsharp06.mp3",
	"vo/mvm/norm/demoman_mvm_painsharp07.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/mvm/norm/demoman_mvm_battlecry02.mp3",
	"vo/mvm/norm/demoman_mvm_battlecry03.mp3",
	"vo/mvm/norm/demoman_mvm_battlecry04.mp3",
	"vo/mvm/norm/demoman_mvm_battlecry07.mp3",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/stickybomblauncher_shoot.wav",
};

void IberiaSeaXploder_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	PrecacheModel("models/props_lakeside_event/bomb_temp.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Sea-Xploder");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_sea_xploder");
	strcopy(data.Icon, sizeof(data.Icon), "demo");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_IberiaExpiAlliance;
	data.Func = ClotSummon;
	NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return IberiaSeaXploder(vecPos, vecAng, team);
}
methodmap IberiaSeaXploder < CClotBody
{
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
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	property float m_flWeaponSwitchCooldown
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	
	
	property float m_flTimeUntillExplosion
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
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

	public IberiaSeaXploder(float vecPos[3], float vecAng[3], int ally)
	{
		IberiaSeaXploder npc = view_as<IberiaSeaXploder>(CClotBody(vecPos, vecAng, "models/player/demo.mdl", "1.0", "3500", ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.SetActivity("ACT_MP_RUN_PRIMARY");
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(IberiaSeaXploder_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(IberiaSeaXploder_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(IberiaSeaXploder_ClotThink);
		
		
		
		npc.StartPathing();
		npc.m_flSpeed = 330.0;
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
	
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_stickybomb_launcher/c_stickybomb_launcher.mdl");

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/demo/dec22_plaid_lad_style3/dec22_plaid_lad_style3.mdl");
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/demo/hwn2022_alcoholic_automaton_style2/hwn2022_alcoholic_automaton_style2.mdl");
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/demo/hwn2023_mad_lad/hwn2023_mad_lad.mdl");

		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);

		return npc;
	}
}

public void IberiaSeaXploder_ClotThink(int iNPC)
{
	IberiaSeaXploder npc = view_as<IberiaSeaXploder>(iNPC);
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
		int ActionDo = IberiaSeaXploderSelfDefense(npc,GetGameTime(npc.index), flDistanceToTarget); 
		switch(ActionDo)
		{
			case 0:
			{
				npc.StartPathing();
				//We run at them.
				if(flDistanceToTarget < npc.GetLeadRadius()) 
				{
					float vPredictedPos[3];
					PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
					npc.SetGoalVector(vPredictedPos);
				}
				else 
				{
					npc.SetGoalEntity(npc.m_iTarget);
				}
				npc.m_flSpeed = 280.0;
				npc.m_bAllowBackWalking = false;
			}
			case 1:
			{
				npc.m_bAllowBackWalking = true;
				float vBackoffPos[3];
				BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget,_,vBackoffPos);
				npc.SetGoalVector(vBackoffPos, true); //update more often, we need it
				npc.m_flSpeed = 220.0;
			}
		}
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action IberiaSeaXploder_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	IberiaSeaXploder npc = view_as<IberiaSeaXploder>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void IberiaSeaXploder_NPCDeath(int entity)
{
	IberiaSeaXploder npc = view_as<IberiaSeaXploder>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
		
	if(IsValidEntity(npc.m_iWearable7))
		RemoveEntity(npc.m_iWearable7);
	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);
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

int IberiaSeaXploderSelfDefense(IberiaSeaXploder npc, float gameTime, float distance)
{
	//Direct mode
	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 10.0))
		{
			float VecAim[3]; WorldSpaceCenter(npc.m_iTarget, VecAim );
			npc.FaceTowards(VecAim, 20000.0);
			int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.PlayMeleeSound();
				float RocketDamage = 125.0;
				float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
				float VecStart[3]; WorldSpaceCenter(npc.index, VecStart );
				npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY",_,_,_,0.75);
				float SpeedReturn[3];

				int RocketGet = npc.FireGrenade(vecTarget);
				IberiaSeaXploder_ShootRollingMineToEnemy(npc.index, RocketGet, RocketDamage, 65.0, 3.0);
				//Reducing gravity, reduces speed, lol.
				SetEntityGravity(RocketGet, 1.0); 	
				//I dont care if its not too accurate, ig they suck with the weapon idk lol, lore.
				ArcToLocationViaSpeedProjectile(VecStart, vecTarget, SpeedReturn, 1.75, 1.0);
				TeleportEntity(RocketGet, NULL_VECTOR, NULL_VECTOR, SpeedReturn);

				//This will return vecTarget as the speed we need.
						
				npc.m_flNextMeleeAttack = gameTime + 2.35;
				//Launch something to target, unsure if rocket or something else.
				//idea:launch fake rocket with noclip or whatever that passes through all
				//then whereever the orginal goal was, land there.
				//it should be a mortar.
			}
		}
	}
	//No can shooty.
	//Enemy is close enough.
	if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 9.0))
	{
		if(Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
		{
			float VecAim[3]; WorldSpaceCenter(npc.m_iTarget, VecAim );
			npc.FaceTowards(VecAim, 20000.0);
			//stand
			return 1;
		}
		//cant see enemy somewhy.
		return 0;
	}
	else //enemy is too far away.
	{
		return 0;
	}
}


void IberiaSeaXploder_ShootRollingMineToEnemy(int iNpc, int Projectile, float damage, float radius, float MaxDurationC4)
{
	DataPack pack;
	CreateDataTimer(0.1, Timer_SeaXploderC4, pack, TIMER_REPEAT);
	pack.WriteCell(EntIndexToEntRef(iNpc));
	pack.WriteCell(EntIndexToEntRef(Projectile));
	pack.WriteFloat(0.0); //Throttle
	pack.WriteFloat(MaxDurationC4 + GetGameTime());
	pack.WriteFloat(damage);
	pack.WriteFloat(radius);
}


public Action Timer_SeaXploderC4(Handle timer, DataPack pack)
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
	{
		//The projectile stopped existing.
		return Plugin_Stop;
	}
	float C4_TrottleTime = pack.ReadFloat();
	if(C4_TrottleTime > GetGameTime())
	{
		return Plugin_Continue;
	}
	
	float C4_TimeUntillBoom = pack.ReadFloat();
	float DurationOfBlink = C4_TimeUntillBoom - GetGameTime();

	DurationOfBlink *= 0.3;
	if(DurationOfBlink > 0.5)
	{
		DurationOfBlink = 0.5;
	}
	else if(DurationOfBlink < 0.1)
	{
		DurationOfBlink = 0.1;
	}

	float pos[3]; GetEntPropVector(Projectile, Prop_Data, "m_vecAbsOrigin", pos);
	pos[2] += 5.0;
	C4_TrottleTime = GetGameTime() + DurationOfBlink;
	pack.Position--;
	pack.Position--;
	pack.WriteFloat(C4_TrottleTime);
	pack.Position++;
	float C4_Damage = pack.ReadFloat();
	float C4_Radius = pack.ReadFloat();
	spawnRing_Vectors(pos, C4_Radius * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 125, 125, 125, 200, 1, DurationOfBlink, 2.0, 2.0, 2, 1.0);


	if(C4_TimeUntillBoom < GetGameTime())
	{
		//Cancel.
		DataPack pack_boom = new DataPack();
		pack_boom.WriteFloat(pos[0]);
		pack_boom.WriteFloat(pos[1]);
		pack_boom.WriteFloat(pos[2]);
		pack_boom.WriteCell(0);
		RequestFrame(MakeExplosionFrameLater, pack_boom);
		EmitAmbientSound("ambient/explosions/explode_3.wav", pos, _, 80, _,0.6, GetRandomInt(75, 110));
		Explode_Logic_Custom(C4_Damage , OwnerNpc , OwnerNpc , -1 , pos , C4_Radius);	//acts like a rocket
		RemoveEntity(Projectile);
		return Plugin_Stop;
	}
	return Plugin_Continue;

}