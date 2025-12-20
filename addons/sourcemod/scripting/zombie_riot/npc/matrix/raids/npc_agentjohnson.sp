#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/spy_paincrticialdeath01.mp3",
	"vo/spy_paincrticialdeath02.mp3",
	"vo/spy_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/spy_painsharp01.mp3",
	"vo/spy_painsharp02.mp3",
	"vo/spy_painsharp03.mp3",
	"vo/spy_painsharp04.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/spy_stabtaunt06.mp3",
	"vo/spy_stabtaunt12.mp3",
	"vo/taunts/spy_taunts01.mp3",
	"vo/taunts/spy_taunts15.mp3",
	"vo/taunts/spy_taunts16.mp3",
};

static const char g_MeleeAttackSounds[][] = {
	"player/taunt_yeti_standee_demo_swing.wav",
	"player/taunt_yeti_standee_engineer_kick.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/cbar_hitbod1.wav",
	"weapons/cbar_hitbod2.wav",
	"weapons/cbar_hitbod3.wav",
};

static char g_RangedAttackSounds[][] = {
	"weapons/revolver_shoot.wav",
};

static char g_RangedReloadSound[][] = {
	"weapons/revolver_worldreload.wav",
};
static char g_WarningSounds[][] = {
	"weapons/vaccinator_charge_tier_03.wav",
};
static char g_SlamSounds[][] = {
	"vo/taunts/spy/spy_taunt_exert_12.mp3",
	"vo/taunts/spy/spy_taunt_flip_end_12.mp3",
	"ambient/levels/labs/electric_explosion1.wav",
	"ambient/levels/labs/electric_explosion2.wav",
};

void AgentJohnson_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Agent Johnson");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_agent_johnson");
	strcopy(data.Icon, sizeof(data.Icon), "matrix_agent_johnson");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Matrix;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
}


static void ClotPrecache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_RangedAttackSounds);
	PrecacheSoundArray(g_RangedReloadSound);
	PrecacheSoundArray(g_WarningSounds);
	PrecacheSoundArray(g_SlamSounds);
	PrecacheModel("models/player/spy.mdl");
	PrecacheSoundCustom("#zombiesurvival/matrix/navras.mp3");
	
	Matrix_Shared_CorruptionPrecache();
}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return AgentJohnson(vecPos, vecAng, ally, data);
}
methodmap AgentJohnson < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);

	}
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, _, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 95);
		
	}
	public void PlayRangedReloadSound() {
		EmitSoundToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, _, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 95);
	}
	public void PlaySlamWarningSound() {
		EmitSoundToAll(g_WarningSounds[GetRandomInt(0, sizeof(g_WarningSounds) - 1)], _, _, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(70, 95));
	}
	public void PlaySlamSound(int usage) {
		EmitSoundToAll(g_SlamSounds[usage], this.index, _, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, 1.0);
		EmitSoundToAll(g_SlamSounds[usage], this.index, _, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, 0.5);
	}
	
	
	public AgentJohnson(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		AgentJohnson npc = view_as<AgentJohnson>(CClotBody(vecPos, vecAng, "models/player/spy.mdl", "1.10", "700", ally));
		
		i_NpcWeight[npc.index] = 4;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");

		RaidBossActive = EntIndexToEntRef(npc.index);
		RaidAllowsBuildings = false;
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iAttacksTillReload = 12;

		npc.m_fbGunout = false;

		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(AgentJohnson_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(AgentJohnson_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(AgentJohnson_ClotThink);

		EmitSoundToAll("weapons/physgun_off.wav", _, _, _, _, 1.0);	
		EmitSoundToAll("weapons/physgun_off.wav", _, _, _, _, 1.0);	

		RaidModeTime = GetGameTime(npc.index) + 185.0;
		b_thisNpcIsARaid[npc.index] = true;
		b_ThisNpcIsImmuneToNuke[npc.index] = true;
		
		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				LookAtTarget(client_check, npc.index);
				SetGlobalTransTarget(client_check);
				ShowGameText(client_check, "item_armor", 1, "%s", "Agent Johnson clocks in");
			}
		}
		
		char buffers[3][64];
		ExplodeString(data, ";", buffers, sizeof(buffers), sizeof(buffers[]));
		//the very first and 2nd char are SC for scaling
		if(buffers[0][0] == 's' && buffers[0][1] == 'c')
		{
			//remove SC
			ReplaceString(buffers[0], 64, "sc", "");
			float value = StringToFloat(buffers[0]);
			RaidModeScaling = value;
		}
		else
		{	
			RaidModeScaling = float(Waves_GetRoundScale()+1);
		}

		if(RaidModeScaling < 35)
		{
			RaidModeScaling *= 0.25; //abit low, inreacing
		}
		else
		{
			RaidModeScaling *= 0.5;
		}
		float amount_of_people = float(CountPlayersOnRed());
		
		if(amount_of_people > 12.0)
		{
			amount_of_people = 12.0;
		}
		
		amount_of_people *= 0.15;
		
		if(amount_of_people < 1.0)
			amount_of_people = 1.0;
			
		RaidModeScaling *= amount_of_people;
		
		MusicEnum music;
		strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/matrix/navras.mp3");
		music.Time = 181;
		music.Volume = 1.3;
		music.Custom = true;
		strcopy(music.Name, sizeof(music.Name), "Navras");
		strcopy(music.Artist, sizeof(music.Artist), "Juno Reactor");
		Music_SetRaidMusic(music);

		//IDLE
		npc.m_iState = 0;
		npc.m_iAnimationState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		npc.m_flSpeed = 200.0;
		npc.m_flAbilityOrAttack0 = GetGameTime(npc.index) + 10.0;
		npc.m_flAbilityOrAttack1 = 0.0;
		npc.m_flAbilityOrAttack2 = 0.0;
		npc.m_flAbilityOrAttack3 = 0.0;
				
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
	
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_ambassador/c_ambassador_xmas.mdl");
		SetVariantString("1.10");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/spy/spy_hat.mdl");
		SetVariantString("1.10");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/all_class/jul13_sweet_shades_s1/jul13_sweet_shades_s1_spy.mdl");
		SetVariantString("1.10");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		npc.m_iWearable4 = npc.EquipItem("head", "models/player/items/spy/tneck.mdl");
		SetVariantString("1.10");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");

		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);

		SetEntityRenderColor(npc.m_iWearable3, 0, 0, 0, 255);
		AcceptEntityInput(npc.m_iWearable1, "Disable");
		
		return npc;
	}
}

public void Johnson_GroundCheck(int entity, int victim, float damage, int weapon)
{
	Custom_Knockback(entity, victim, 1000.0, true);
}

public void AgentJohnson_ClotThink(int iNPC)
{
	AgentJohnson npc = view_as<AgentJohnson>(iNPC);
	
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	if(LastMann)
	{
		if(!npc.m_fbGunout)
		{
			npc.m_fbGunout = true;
			switch(GetRandomInt(0,1))
			{
				case 0:
				{
					CPrintToChatAll("{community}존슨 요원{default}: 네가 살아있을 가치가 있나?");
				}
				case 1:
				{
					CPrintToChatAll("{community}존슨 요원{default}: 인간의 정신은 너무나도 나약하다.");
				}
			}
		}
	}

	if(i_RaidGrantExtra[npc.index] == RAIDITEM_INDEX_WIN_COND)
	{
		func_NPCThink[npc.index] = INVALID_FUNCTION;
		
		CPrintToChatAll("{community}존슨 요원{default}: 네 이야기는 여기서 끝이다.");
		return;
	}

	//idk it never was in a bracket
	if(IsValidEntity(RaidBossActive) && RaidModeTime < GetGameTime())
	{
		if(RaidModeTime < GetGameTime())
		{
			ForcePlayerLoss();
			RaidBossActive = INVALID_ENT_REFERENCE;
			CPrintToChatAll("{community}존슨 요원{default}: {default}망명자들의 이야기는 여기서 끝이다.{default}");
			func_NPCThink[npc.index] = INVALID_FUNCTION;
			return;
		}
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

	if(npc.m_flAbilityOrAttack1)
	{
		if(npc.m_flAbilityOrAttack1 < GetGameTime(npc.index))
		{
			float radius = 300.0;
			float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
			pos[2] += 5.0;
			int color[4] = {255, 50, 40, 255};
			if(npc.m_iAnimationState != 999)
			{
				i_NpcWeight[npc.index] = 999;
				npc.m_flAbilityOrAttack2 = GetGameTime(npc.index) + 0.65;
				b_NoGravity[npc.index] = true;
				npc.SetVelocity({0.0,0.0,0.0});
				npc.m_bisWalking = false;
				npc.m_iAnimationState = 999;
				
				return;
			}
			if(npc.IsOnGround())
			{
				npc.m_iAnimationState = 0;
				npc.m_bisWalking = true;
				int iActivity_melee = npc.LookupActivity("ACT_MP_RUN_SECONDARY");
				if(iActivity_melee > 0) 
					npc.StartActivity(iActivity_melee);
				i_NpcWeight[npc.index] = 4;
				npc.m_flAbilityOrAttack0 = GetGameTime(npc.index) + 17.0;
				npc.m_flAbilityOrAttack1 = 0.0;
				npc.m_flAbilityOrAttack2 = 0.0;
				npc.m_flAbilityOrAttack3 = 0.0;
				spawnRing_Vectors(pos, radius * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", color[0], color[1], color[2], color[3], 1, 0.33, 6.0, 0.1, 1, 1.0);
				float damage = 60.0;
				damage *= RaidModeScaling;
				Explode_Logic_Custom(damage , npc.index , npc.index , -1 , pos, radius, _, _, false, 99,_,_,_, Johnson_GroundCheck);	//acts like a rocket
				
				DataPack pack_boom = new DataPack();
				pack_boom.WriteFloat(pos[0]);
				pack_boom.WriteFloat(pos[1]);
				pack_boom.WriteFloat(pos[2]);
				pack_boom.WriteCell(1);
				RequestFrame(MakeExplosionFrameLater, pack_boom);
				npc.PlaySlamSound(1);
				npc.PlaySlamSound(GetRandomInt(2, 3));
				return;
			}
			if(npc.m_flAbilityOrAttack2)
			{
				if(npc.m_flAbilityOrAttack2 <= GetGameTime(npc.index))
				{
					b_NoGravity[npc.index] = false;
					npc.m_flAbilityOrAttack2 = GetGameTime(npc.index) + 0.1;
					npc.SetVelocity({0.0,0.0, -1000.0});
				}
				else
				{
					if(npc.m_flAbilityOrAttack3 <= GetGameTime(npc.index))
					{
						npc.m_flAbilityOrAttack3 = GetGameTime(npc.index) + 0.1;
						spawnRing_Vectors(pos, radius * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", color[0], color[1], color[2], color[3], 1, 0.33, 6.0, 0.1, 1, 1.0);
					}
					
				}
				return;
			}
		}
	}
	
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	int closest = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, closest))
	{
		float vecTarget[3]; WorldSpaceCenter(closest, vecTarget);
			
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		float gameTime = GetGameTime(npc.index);
		//Predict their pos.
		if(flDistanceToTarget < npc.GetLeadRadius())
		{
			float vPredictedPos[3]; PredictSubjectPosition(npc, closest, _, _, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else
		{
			npc.SetGoalEntity(closest);
		}

		if(npc.m_flAbilityOrAttack0)//Slam Prepare
		{
			if(npc.m_flAbilityOrAttack0 < gameTime)
			{
				if(flDistanceToTarget <= (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.2))
				{
					EmitSoundToAll("mvm/mvm_cpoint_klaxon.wav", _, _, _, _, 1.0);
					EmitSoundToAll("mvm/mvm_cpoint_klaxon.wav", _, _, _, _, 1.0);
					static float flPos[3]; 
					GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flPos);
					flPos[2] += 5.0;
					ParticleEffectAt(flPos, "taunt_flip_land_red", 0.25);
					npc.AddActivityViaSequence("airwalk_ITEM1");
					flPos[2] += 500.0;
					npc.SetVelocity({0.0,0.0,0.0});
					PluginBot_Jump(npc.index, flPos);
					npc.FaceTowards(vecTarget, 99999.9);
					npc.m_flAbilityOrAttack1 = gameTime + 0.45;
					npc.PlaySlamSound(0);
					return;
				}
			}
		}
		
		Johnsons_SelfDefense(npc, gameTime, npc.m_iTarget, flDistanceToTarget);
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

static void Johnsons_SelfDefense(AgentJohnson npc, float gameTime, int target, float flDistanceToTarget)
{
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < GetGameTime(npc.index))
		{
			npc.m_flAttackHappens = 0.0;
			
			if(IsValidEnemy(npc.index, target))
			{
				int HowManyEnemeisAoeMelee = 64;
				Handle swingTrace;
				float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
				npc.FaceTowards(VecEnemy, 15000.0);
				npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, 1, _, HowManyEnemeisAoeMelee);
				delete swingTrace;
				bool PlaySound = false;
				float damage = 20.0;
				damage *= RaidModeScaling;
				bool silenced = NpcStats_IsEnemySilenced(npc.index);
				for(int counter = 1; counter <= HowManyEnemeisAoeMelee; counter++)
				{
					if(i_EntitiesHitAoeSwing_NpcSwing[counter] > 0)
					{
						if(IsValidEntity(i_EntitiesHitAoeSwing_NpcSwing[counter]))
						{
							int targetTrace = i_EntitiesHitAoeSwing_NpcSwing[counter];
							float vecHit[3];
							
							WorldSpaceCenter(targetTrace, vecHit);

							if(damage <= 1.0)
							{
								damage = 1.0;
							}
							Elemental_AddCorruptionDamage(targetTrace, npc.index, 15);
							SDKHooks_TakeDamage(targetTrace, npc.index, npc.index, damage, DMG_CLUB, -1, _, vecHit);
							//Reduce damage after dealing
							damage *= 0.92;
							// On Hit stuff
							bool Knocked = false;
							if(!PlaySound)
							{
								PlaySound = true;
							}
							
							if(IsValidClient(targetTrace))
							{
								if (IsInvuln(targetTrace))
								{
									Knocked = true;
									Custom_Knockback(npc.index, targetTrace, 180.0, true);
									if(!silenced)
									{
										TF2_AddCondition(targetTrace, TFCond_LostFooting, 0.25);
										TF2_AddCondition(targetTrace, TFCond_AirCurrent, 0.25);
									}
								}
								else
								{
									if(!silenced)
									{
										TF2_AddCondition(targetTrace, TFCond_LostFooting, 0.25);
										TF2_AddCondition(targetTrace, TFCond_AirCurrent, 0.25);
									}
								}
							}
										
							if(!Knocked)
								Custom_Knockback(npc.index, targetTrace, 225.0, true); 
						} 
					}
				}
				if(PlaySound)
				{
					npc.PlayMeleeHitSound();
				}
			}
		}
	}

	if(npc.m_flNextRangedSpecialAttack)
	{
		if(npc.m_flNextRangedSpecialAttack < gameTime)
		{
			npc.m_flNextRangedSpecialAttack = 0.0;
			
			if(npc.m_iTarget > 0)
			{
				float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
				float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);
				npc.FaceTowards(vecTarget, 150.0);
				
				float eyePitch[3], vecDirShooting[3];
				GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
				
				vecTarget[2] += 15.0;
				MakeVectorFromPoints(vecMe, vecTarget, vecDirShooting);
				GetVectorAngles(vecDirShooting, vecDirShooting);

				vecDirShooting[1] = eyePitch[1];

				npc.m_flNextRangedAttack = gameTime + 0.5;
				npc.m_iAttacksTillReload--;

				if(npc.m_iAttacksTillReload < 1)
				{
					npc.AddGesture("ACT_MP_RELOAD_STAND_SECONDARY");
					npc.m_flReloadDelay = GetGameTime(npc.index) + 1.4;
					npc.m_iAttacksTillReload = 12;
					npc.PlayRangedReloadSound();
				}
				
				float x = GetRandomFloat( -0.15, 0.15 );
				float y = GetRandomFloat( -0.15, 0.15 );
				
				float vecRight[3], vecUp[3];
				GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
				
				float vecDir[3];
				for(int i; i < 3; i++)
				{
					vecDir[i] = vecDirShooting[i] + x * vecRight[i] + y * vecUp[i]; 
				}

				NormalizeVector(vecDir, vecDir);
				npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY");
				KillFeed_SetKillIcon(npc.index, "pistol");

				float damage = 8.0;
				damage *= RaidModeScaling;

				FireBullet(npc.index, npc.m_iWearable1, vecMe, vecDir, damage, 9000.0, DMG_BULLET, "dxhr_sniper_rail_blue");
				
				npc.PlayRangedSound();
			}
		}
		return;
	}

	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.25))
		{
			int Enemy_I_See;
			Enemy_I_See = Can_I_See_Enemy(npc.index, target);

			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				Johnsons_WeaponSwaps(npc);
				npc.m_iTarget = Enemy_I_See;

				npc.PlayMeleeSound();
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");//He will SMACK you
				npc.m_flAttackHappens = gameTime + 0.1;
				float attack = 1.0;
				npc.m_flNextMeleeAttack = gameTime + attack;
				return;
			}
		}
	}

	if(gameTime > npc.m_flNextRangedAttack)
	{
		if(flDistanceToTarget > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.25) && flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 7.0))
		{
			int Enemy_I_See;
			Enemy_I_See = Can_I_See_Enemy(npc.index, target);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				Johnsons_WeaponSwaps(npc, 2);
				npc.m_iTarget = Enemy_I_See;
				npc.PlayRangedSound();
				npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY");//ACT_MP_ATTACK_STAND_ITEM1 | ACT_MP_ATTACK_STAND_MELEE_ALLCLASS
						
				npc.m_flNextRangedSpecialAttack = gameTime + 0.15;
				npc.m_flNextRangedAttack = gameTime + 1.85;
			}
		}
	}
}

static void Johnsons_WeaponSwaps(AgentJohnson npc, int number = 1)
{
	switch(number)
	{
		case 1:
		{
			if(npc.m_iChanged_WalkCycle != 3)
			{
				int iActivity_melee = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
				if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
				AcceptEntityInput(npc.m_iWearable1, "Disable");
				npc.m_iChanged_WalkCycle = 3;
			}
		}
		case 2:
		{
			if(npc.m_iChanged_WalkCycle != 4)
			{
				int iActivity_melee = npc.LookupActivity("ACT_MP_RUN_SECONDARY");
				if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
				AcceptEntityInput(npc.m_iWearable1, "Enable");
				npc.m_iChanged_WalkCycle = 4;
			}
		}
	}
}

static Action AgentJohnson_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	AgentJohnson npc = view_as<AgentJohnson>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	return Plugin_Changed;
}

public void AgentJohnson_NPCDeath(int entity)
{
	AgentJohnson npc = view_as<AgentJohnson>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
		
	Music_SetRaidMusicSimple("vo/null.mp3", 60, false, 0.5);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

}