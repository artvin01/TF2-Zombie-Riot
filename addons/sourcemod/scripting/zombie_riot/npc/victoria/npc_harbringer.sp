#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	")vo/soldier_negativevocalization01.mp3",
	")vo/soldier_negativevocalization02.mp3",
	")vo/soldier_negativevocalization03.mp3",
	")vo/soldier_negativevocalization04.mp3",
	")vo/soldier_negativevocalization05.mp3",
	")vo/soldier_negativevocalization06.mp3"
};

static const char g_HurtSounds[][] = {
	"vo/soldier_painsharp01.mp3",
	"vo/soldier_painsharp02.mp3",
	"vo/soldier_painsharp03.mp3",
	"vo/soldier_painsharp04.mp3",
	"vo/soldier_painsharp05.mp3",
	"vo/soldier_painsharp06.mp3",
	"vo/soldier_painsharp07.mp3",
	"vo/soldier_painsharp08.mp3"
};

static const char g_ExplosionSounds[][]= {
	"weapons/explode1.wav",
	"weapons/explode2.wav",
	"weapons/explode3.wav"
};

static const char g_IdleAlertedSounds[][] = {
	"vo/taunts/soldier_taunts19.mp3",
	"vo/taunts/soldier_taunts20.mp3",
	"vo/taunts/soldier_taunts21.mp3",
	"vo/taunts/soldier_taunts18.mp3",
	"vo/compmode/cm_soldier_pregamefirst_03.mp3"
};

static const char g_RangeAttackSounds[] = "weapons/csgo_awp_shoot.wav";

static bool b_TheGoons;
static bool b_KillIconSwitch[MAXENTITIES];
static int CanteenModels;
static int BeamIndex;
static float fl_Har_Delay[MAXENTITIES];
static float fl_Har_Duration[MAXENTITIES];

void VictoriaHarbringer_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Harbringer");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_harbringer");
	strcopy(data.Icon, sizeof(data.Icon), "knight");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_Victoria;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_ExplosionSounds);
	PrecacheSound(g_RangeAttackSounds);
	PrecacheModel("models/player/soldier.mdl");
	CanteenModels = PrecacheModel("models/workshop/player/items/scout/robo_all_mvm_canteen/robo_all_mvm_canteen.mdl");
	BeamIndex = PrecacheModel("materials/sprites/laserbeam.vmt", true);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return VictoriaHarbringer(vecPos, vecAng, ally, data);
}

methodmap VictoriaHarbringer < CClotBody
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
	public void PlayRangeSound()
	{
		EmitSoundToAll(g_RangeAttackSounds, this.index, SNDCHAN_AUTO, 70, _, 0.6);
	}
	public void PlayThrowSound()
	{
		EmitSoundToAll("weapons/slam/throw.wav", this.index, SNDCHAN_AUTO, 80, _, 0.7);
	}
	
	property int m_iBirdEye
	{
		public get()							{ return i_AmountProjectiles[this.index]; }
		public set(int TempValueForProperty) 	{ i_AmountProjectiles[this.index] = TempValueForProperty; }
	}
	property int m_iBigPipe
	{
		public get()							{ return this.m_iState; }
		public set(int TempValueForProperty) 	{ this.m_iState = TempValueForProperty; }
	}
	property float m_flFlashGrenade
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flArmorGrenade
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}

	public VictoriaHarbringer(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		VictoriaHarbringer npc = view_as<VictoriaHarbringer>(CClotBody(vecPos, vecAng, "models/player/soldier.mdl", "1.1", "1000", ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_SECONDARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(2);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		b_TheGoons=false;
		if(StrContains(data, "icononly") != -1)
		{
			func_NPCDeath[npc.index] = INVALID_FUNCTION;
			func_NPCOnTakeDamage[npc.index] = INVALID_FUNCTION;
			func_NPCThink[npc.index] = INVALID_FUNCTION;
			
			b_NpcForcepowerupspawn[npc.index] = 0;
			i_RaidGrantExtra[npc.index] = 0;
			b_DissapearOnDeath[npc.index] = true;
			b_DoGibThisNpc[npc.index] = true;
			SmiteNpcToDeath(npc.index);
			return npc;
		}
		
		if(StrContains(data, "the_goons") != -1)
			b_TheGoons=true;
		else if(StrContains(data, "birdeye"))
		{
			npc.m_iBirdEye=-1;
			npc.m_iBigPipe=-1;
			//The NPC name will be displayed normally only after 1 frame.
			switch(GetRandomInt(0, 3))
			{
				case 0:NPCPritToChat(npc.index, "{sienna}", "harbringer_Talk_01-1", false, true);
				case 1:NPCPritToChat(npc.index, "{sienna}", "harbringer_Talk_01-2", false, true);
				case 2:NPCPritToChat(npc.index, "{sienna}", "harbringer_Talk_01-3", false, true);
				case 3:NPCPritToChat(npc.index, "{sienna}", "harbringer_Talk_01-4", false, true);
			}
		}
		
		func_NPCDeath[npc.index] = VictoriaHarbringer_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = VictoriaHarbringer_OnTakeDamage;
		func_NPCThink[npc.index] = VictoriaHarbringer_ClotThink;
		
		//IDLE
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		npc.m_flSpeed = 330.0;
		npc.m_flFlashGrenade = 0.0;
		npc.m_flArmorGrenade = 0.0;
		b_KillIconSwitch[npc.index]=false;
		
		b_ThisNpcIsImmuneToNuke[npc.index] = true;
		GiveNpcOutLineLastOrBoss(npc.index, true);
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable1 = npc.EquipItem("head", WEAPON_CUSTOM_WEAPONRY_1);
		SetVariantString("0.9");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		SetVariantInt(32);
		AcceptEntityInput(npc.m_iWearable1, "SetBodyGroup");

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/spy/sum22_night_vision_gawkers/sum22_night_vision_gawkers.mdl");
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/soldier/hwn2022_cranial_cowl/hwn2022_cranial_cowl.mdl");
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/soldier/sum24_pathfinder_style2/sum24_pathfinder_style2.mdl");
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		npc.m_iWearable5 = npc.EquipItem("head", "models/weapons/c_models/c_battalion_buffpack/c_batt_buffpack.mdl");
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		if(b_TheGoons)
		{
			npc.m_iWearable6 = npc.EquipItem("head", "models/weapons/c_models/c_battalion_buffbanner/c_batt_buffbanner.mdl");
			SetVariantString("1.75");
			AcceptEntityInput(npc.m_iWearable6, "SetModelScale");

			npc.m_iWearable7 = ParticleEffectAt_Parent(vecPos, "utaunt_aestheticlogo_teamcolor_blue", npc.index, "m_vecAbsOrigin", {0.0,0.0,0.0});
			npc.m_flRangedArmor -= 0.3;
			npc.m_flFlashGrenade = GetGameTime(npc.index)+10.0;
			npc.m_flArmorGrenade = GetGameTime(npc.index)+8.0;
		}
		return npc;
	}
}

static void VictoriaHarbringer_ClotThink(int iNPC)
{
	VictoriaHarbringer npc = view_as<VictoriaHarbringer>(iNPC);
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

	if(b_TheGoons)
	{
		int team = GetTeam(npc.index);
		if(team == 2)
		{
			for(int client = 1; client <= MaxClients; client++)
			{
				if(IsClientInGame(client) && IsEntityAlive(client))
				{
					ApplyStatusEffect(npc.index, client, "Call To Victoria", 2.0);
				}
			}
		}
		for(int i; i < i_MaxcountNpcTotal; i++)
		{
			int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
			if(entity != INVALID_ENT_REFERENCE && IsEntityAlive(entity))
			{
				if(GetTeam(entity) == team)
				{
					ApplyStatusEffect(npc.index, entity, "Call To Victoria", 0.5);
				}
			}
		}
	}

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	if(!IsEntityAlive(npc.m_iBirdEye)&&npc.m_iBirdEye!=-1)
	{
		switch(GetRandomInt(0, 2))
		{
			case 0:NPCPritToChat(npc.index, "{sienna}", "harbringer_Talk_02-1", false, false);
			case 1:NPCPritToChat(npc.index, "{sienna}", "harbringer_Talk_02-2", false, false);
			case 2:NPCPritToChat(npc.index, "{sienna}", "harbringer_Talk_02-3", false, false);
		}
		npc.m_iBirdEye=-1;
	}
	
	if(!IsEntityAlive(npc.m_iBigPipe)&&npc.m_iBigPipe!=-1)
	{
		switch(GetRandomInt(0, 2))
		{
			case 0:NPCPritToChat(npc.index, "{sienna}", "harbringer_Talk_03-1", false, false);
			case 1:NPCPritToChat(npc.index, "{sienna}", "harbringer_Talk_03-2", false, false);
			case 2:NPCPritToChat(npc.index, "{sienna}", "harbringer_Talk_03-3", false, false);
		}
		npc.m_iBigPipe=-1;
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
			npc.SetGoalVector(vPredictedPos);
		}
		else 
		{
			npc.SetGoalEntity(npc.m_iTarget);
		}
		VictoriaHarbringerSelfDefense(npc,GetGameTime(npc.index)); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

static Action VictoriaHarbringer_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VictoriaHarbringer npc = view_as<VictoriaHarbringer>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	if(NpcStats_VictorianCallToArms(npc.index))
	{
		int health = ReturnEntityMaxHealth(npc.index) / 30;

		if(damage > float(health))
		{
			damage = float(health);
		}
	}
	
	return Plugin_Changed;
}

static void VictoriaHarbringer_NPCDeath(int entity)
{
	VictoriaHarbringer npc = view_as<VictoriaHarbringer>(entity);
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

static void VictoriaHarbringerSelfDefense(VictoriaHarbringer npc, float gameTime)
{
	int target;
	//some Ranged units will behave differently.
	//not this one.
	target = npc.m_iTarget;
	if(!IsValidEnemy(npc.index,target))
	{
		if(npc.m_iChanged_WalkCycle != 4)
		{
			npc.m_bisWalking = true;
			npc.m_iChanged_WalkCycle = 4;
			npc.SetActivity("ACT_MP_RUN_SECONDARY");
			npc.m_flSpeed = 330.0;
			npc.StartPathing();
		}
		return;
	}
	float vecTarget[3]; WorldSpaceCenter(target, vecTarget);

	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
	if(b_TheGoons&&npc.m_flArmorGrenade<gameTime)
	{
		npc.PlayThrowSound();
		npc.m_flArmorGrenade = gameTime+32.0;
		switch(GetRandomInt(0, 1))
		{
			case 0:NPCPritToChat(npc.index, "{sienna}", "harbringer_Talk_05-1", false, false);
			case 1:NPCPritToChat(npc.index, "{sienna}", "harbringer_Talk_05-2", false, false);
		}
		
		int entity = CreateEntityByName("tf_projectile_pipe_remote");
		if(IsValidEntity(entity))
		{
			SetEntitySpike(entity, 3);
			b_StickyIsSticking[entity] = true;
			
			int team = GetTeam(npc.index);
				
			SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", npc.index);
			SetEntProp(entity, Prop_Send, "m_iTeamNum", team, 1);
			
			SetEntProp(entity, Prop_Send, "m_nSkin", (team-2));
			SetEntPropFloat(entity, Prop_Send, "m_flDamage", 0.0); 
			SetEntPropEnt(entity, Prop_Send, "m_hThrower", npc.index);
			SetEntPropEnt(entity, Prop_Send, "m_hOriginalLauncher", 0);
			SetEntProp(entity, Prop_Send, "m_iType", 1);
				
			for(int i; i<4; i++)
			{
				SetEntProp(entity, Prop_Send, "m_nModelIndexOverrides", CanteenModels, _, i);
			}
			
			SetVariantInt(team);
			AcceptEntityInput(entity, "TeamNum", -1, -1, 0);
			SetVariantInt(team);
			AcceptEntityInput(entity, "SetTeam", -1, -1, 0);
			DispatchSpawn(entity);
			TeleportEntity(entity, VecSelfNpc, NULL_VECTOR, NULL_VECTOR);
			
			IsCustomTfGrenadeProjectile(entity, 9999999.0);
			CClotBody Grenade = view_as<CClotBody>(entity);
			Grenade.m_bThisEntityIgnored = true;
			
			fl_Har_Delay[entity] = GetGameTime() + 1.0;
			fl_Har_Duration[entity] = GetGameTime() + 12.0;
			
			SetEntProp(entity, Prop_Data, "m_nNextThinkTick", -1);
			
			DataPack pack;
			CreateDataTimer(0.1, Timer_NPC_Armor_Grenade, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			pack.WriteCell(EntIndexToEntRef(entity));
			pack.WriteCell(GetTeam(npc.index));
		}
	}
	if(b_TheGoons&&npc.m_flFlashGrenade<gameTime)
	{
		npc.PlayThrowSound();
		npc.m_flFlashGrenade = gameTime+22.0;
		switch(GetRandomInt(0, 1))
		{
			case 0:NPCPritToChat(npc.index, "{sienna}", "harbringer_Talk_06-1", false, false);
			case 1:NPCPritToChat(npc.index, "{sienna}", "harbringer_Talk_06-2", false, false);
		}
		
		int entity = CreateEntityByName("tf_projectile_pipe");
		if(IsValidEntity(entity))
		{
			SetEntitySpike(entity, 3);
			b_StickyIsSticking[entity] = true;
			static float ang[3], vel[3];
			MakeVectorFromPoints(VecSelfNpc, vecTarget, ang);
			GetVectorAngles(ang, ang);
		
			ang[0] -= 8.0;
			
			float speed = 750.0;
			
			vel[0] = Cosine(DegToRad(ang[0]))*Cosine(DegToRad(ang[1]))*speed;
			vel[1] = Cosine(DegToRad(ang[0]))*Sine(DegToRad(ang[1]))*speed;
			vel[2] = Sine(DegToRad(ang[0]))*speed;
			vel[2] *= -1;
			
			int team = GetTeam(npc.index);
				
			SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", npc.index);
			SetEntProp(entity, Prop_Send, "m_iTeamNum", team, 1);
			
			SetEntProp(entity, Prop_Send, "m_nSkin", (team-2));
			SetEntPropFloat(entity, Prop_Send, "m_flDamage", 0.0); 
			SetEntPropEnt(entity, Prop_Send, "m_hThrower", npc.index);
			SetEntPropEnt(entity, Prop_Send, "m_hOriginalLauncher", 0);
				
			SetEntityModel(entity, "models/weapons/w_grenade.mdl");
			
			SetVariantInt(team);
			AcceptEntityInput(entity, "TeamNum", -1, -1, 0);
			SetVariantInt(team);
			AcceptEntityInput(entity, "SetTeam", -1, -1, 0);
			DispatchSpawn(entity);
			TeleportEntity(entity, VecSelfNpc, ang, vel);
			
			IsCustomTfGrenadeProjectile(entity, 9999999.0);
			CClotBody Grenade = view_as<CClotBody>(entity);
			Grenade.m_bThisEntityIgnored = true;
			
			fl_Har_Delay[entity] = GetGameTime() + 1.0;
			fl_Har_Duration[entity] = GetGameTime() + 4.5;
			fl_Extra_Damage[entity] = fl_Extra_Damage[npc.index];
			
			SetEntProp(entity, Prop_Data, "m_nNextThinkTick", -1);
			SDKHook(entity, SDKHook_StartTouch, Flash_Grenade_StartTouch);
			DataPack pack;
			CreateDataTimer(0.1, Timer_NPC_Flash_Grenade, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			pack.WriteCell(EntIndexToEntRef(entity));
			pack.WriteCell(EntIndexToEntRef(npc.index));
		}
	}
	if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 10.0))
	{
		int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);

		if(IsValidEnemy(npc.index, Enemy_I_See))
		{
			if(npc.m_iChanged_WalkCycle != 5)
			{
				npc.m_bisWalking = true;
				npc.m_iChanged_WalkCycle = 5;
				npc.SetActivity("ACT_MP_RUN_SECONDARY");
				npc.m_flSpeed = 200.0;
				npc.StartPathing();
			}	
			if(gameTime > npc.m_flNextMeleeAttack)
			{
				if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 10.0))
				{	
					npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY",_,_,_,2.00);
					npc.PlayRangeSound();
					npc.FaceTowards(vecTarget, 20000.0);
					Handle swingTrace;
					if(npc.DoSwingTrace(swingTrace, target, { 9999.0, 9999.0, 9999.0 }))
					{
						target = TR_GetEntityIndex(swingTrace);	
							
						float vecHit[3];
						TR_GetEndPosition(vecHit, swingTrace);
						float origin[3], angles[3];
						view_as<CClotBody>(npc.index).GetAttachment("effect_hand_r", origin, angles);
						ShootLaser(npc.index, "bullet_tracer02_blue_crit", origin, vecHit, false );
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.05;

						if(IsValidEnemy(npc.index, target))
						{
							float damageDealt = 30.0;
							if(ShouldNpcDealBonusDamage(target))
								damageDealt *= 3.0;
							if(!b_KillIconSwitch[npc.index])
							{
								KillFeed_SetKillIcon(npc.index, "minigun");
								b_KillIconSwitch[npc.index]=true;
							}
							SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_BULLET, -1, _, vecHit);
							if(!IsValidEnemy(npc.index, target))
							{
								switch(GetRandomInt(0, 3))
								{
									case 0:NPCPritToChat(npc.index, "{sienna}", "harbringer_Talk_04-1", false, false);
									case 1:NPCPritToChat(npc.index, "{sienna}", "harbringer_Talk_04-2", false, false);
									case 2:NPCPritToChat(npc.index, "{sienna}", "harbringer_Talk_04-3", false, false);
									case 3:NPCPritToChat(npc.index, "{sienna}", "harbringer_Talk_04-4", false, false);
								}
							}
							else if(b_TheGoons)
								IncreaseEntityDamageTakenBy(target, 0.01, 4.0, true);
						}
					}
					delete swingTrace;
				}
			}
		}
		else
		{
			if(npc.m_iChanged_WalkCycle != 4)
			{
				npc.m_bisWalking = true;
				npc.m_iChanged_WalkCycle = 4;
				npc.SetActivity("ACT_MP_RUN_SECONDARY");
				npc.m_flSpeed = 310.0;
				npc.StartPathing();
			}
		}
	}
	else
	{
		if(npc.m_iChanged_WalkCycle != 4)
		{
			npc.m_bisWalking = true;
			npc.m_iChanged_WalkCycle = 4;
			npc.SetActivity("ACT_MP_RUN_SECONDARY");
			npc.m_flSpeed = 310.0;
			npc.StartPathing();
		}
	}
}

static Action Timer_NPC_Armor_Grenade(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	int team = pack.ReadCell();
	if(IsValidEntity(entity) && entity>MaxClients)
	{
		if(fl_Har_Delay[entity] < GetGameTime())
		{
			float powerup_pos[3];
			float target_pos[3];
			GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", powerup_pos);
			fl_Har_Delay[entity] = GetGameTime() + 1.0;
			TE_SetupBeamRingPoint(powerup_pos, 10.0, 400.0 * 2.0, BeamIndex, -1, 0, 5, 0.5, 5.0, 3.0, {255,255,0,75}, 0, 0);
			TE_SendToAll();
			for (int target = 0; target < MAXENTITIES; target++)
			{
				if(!IsValidEntity(target))
					continue;

				if(GetTeam(target) != team)
					continue;

				GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", target_pos);
				if(GetVectorDistance(powerup_pos, target_pos, true) > (400.0 * 400.0))
					continue;

				if(b_ThisWasAnNpc[target] && IsEntityAlive(target, true))
				{
					float GiveArmor = ReturnEntityMaxHealth(target) * (f_TimeUntillNormalHeal[target] > GetGameTime() ? 0.025 : 0.05);
					GrantEntityArmor(target, false, 1.5, 0.75, 0, GiveArmor);
					continue;
				}
			}
		}
		if(fl_Har_Duration[entity] < GetGameTime())
		{
			RemoveEntity(entity);
			return Plugin_Stop;	
		}
		return Plugin_Continue;
	}
	else
	{
		return Plugin_Stop;	
	}
}

static Action Flash_Grenade_StartTouch(int entity, int target)
{
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if(!IsValidEntity(owner))
		owner = 0;
	int inflictor = h_ArrowInflictorRef[entity];
	if(inflictor != -1)
		inflictor = EntRefToEntIndex(h_ArrowInflictorRef[entity]);

	if(inflictor == -1)
		inflictor = owner;
	float powerup_pos[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", powerup_pos);
	ParticleEffectAt(powerup_pos, "ExplosionCore_MidAir", 1.0);
	EmitSoundToAll(g_ExplosionSounds[GetRandomInt(0, sizeof(g_ExplosionSounds) - 1)], 0, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, _, -1, powerup_pos);
	Explode_Logic_Custom(0.0, owner, inflictor, -1, powerup_pos, 400.0, _, _, true, _, false, _, FlashGrenade);

	RemoveEntity(entity);
	return Plugin_Handled;
}

static Action Timer_NPC_Flash_Grenade(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	int owner = EntRefToEntIndex(pack.ReadCell());
	if(IsValidEntity(entity) && entity>MaxClients)
	{
		if(!IsValidEntity(owner)&&!IsEntityAlive(owner))
		{
			RemoveEntity(entity);
			return Plugin_Stop;
		}
		float powerup_pos[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", powerup_pos);
		if(fl_Har_Delay[entity] < GetGameTime())
		{
			fl_Har_Delay[entity] = GetGameTime() + 1.0;
			TE_SetupBeamRingPoint(powerup_pos, 10.0, 400.0 * 2.0, BeamIndex, -1, 0, 5, 0.5, 5.0, 3.0, {255,100,80,75}, 0, 0);
			TE_SendToAll();
		}
		if(fl_Har_Duration[entity] < GetGameTime())
		{
			ParticleEffectAt(powerup_pos, "ExplosionCore_MidAir", 1.0);
			EmitSoundToAll(g_ExplosionSounds[GetRandomInt(0, sizeof(g_ExplosionSounds) - 1)], 0, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, _, -1, powerup_pos);
			Explode_Logic_Custom(0.0, owner, owner, -1, powerup_pos, 400.0, _, _, true, _, false, _, FlashGrenade);

			RemoveEntity(entity);
			return Plugin_Stop;	
		}
		return Plugin_Continue;
	}
	else
	{
		return Plugin_Stop;	
	}
}

static void FlashGrenade(int entity, int victim, float damage, int weapon)
{
	float vecHit[3]; WorldSpaceCenter(victim, vecHit);
	if(GetTeam(entity) != GetTeam(victim))
	{
		int inflictor = h_ArrowInflictorRef[entity];
		if(inflictor != -1)
			inflictor = EntRefToEntIndex(h_ArrowInflictorRef[entity]);

		if(inflictor == -1)
			inflictor = entity;
		damage = 500.0;
		if(ShouldNpcDealBonusDamage(victim))
			damage *= 3.0;
		if(b_KillIconSwitch[entity])
		{
			KillFeed_SetKillIcon(entity, "taunt_soldier");
			b_KillIconSwitch[entity]=false;
		}
		SDKHooks_TakeDamage(victim, entity, inflictor, damage, DMG_BLAST, -1, _, vecHit);
		if(!HasSpecificBuff(victim, "Fluid Movement") && IsValidClient(victim))
			TF2_StunPlayer(victim, 3.0, 0.3, TF_STUNFLAG_SLOWDOWN);
		ApplyStatusEffect(entity, victim, "Silenced", (IsValidClient(victim) ? 6.0 : (b_thisNpcIsARaid[victim] || b_thisNpcIsABoss[victim] ? 3.0 : 6.0)));
	}
}