#pragma semicolon 1
#pragma newdecls required

static char g_DeathSounds[][] = {
	"freak_fortress_2/pablonew/pablo_death1.mp3",
	"freak_fortress_2/pablonew/pablo_death2.mp3",
	"freak_fortress_2/pablonew/pablo_death3.mp3",
};

static char g_HurtSounds[][] = {
	"vo/spy_painsharp01.mp3",
	"vo/spy_painsharp02.mp3",
	"vo/spy_painsharp03.mp3",
	"vo/spy_painsharp04.mp3",
};

static char g_IdleSounds[][] = {
	"vo/spy_laughshort01.mp3",
	"vo/spy_laughshort02.mp3",
	"vo/spy_laughshort03.mp3",
	"vo/spy_laughshort04.mp3",
	"vo/spy_laughshort05.mp3",
	"vo/spy_laughshort06.mp3",
};

static char g_IdleAlertedSounds[][] = {
	"misc/null.wav",
	//"vo/spy_battlecry01.mp3",
	//"vo/spy_battlecry02.mp3",
	//"vo/spy_battlecry03.mp3",
	//"vo/spy_battlecry04.mp3",
};

static char g_MeleeHitSounds[][] = {
	"vo/spy_laughshort01.mp3",
};

static char g_MeleeAttackSounds[][] = {
	"weapons/blade_hit1.wav",
	"weapons/blade_hit2.wav",
	"weapons/blade_hit3.wav",
	"weapons/blade_hit4.wav",
};

static char g_MeleeMissSounds[][] = {
	"weapons/knife_swing.wav",
};

static char g_RangedReloadSound[][] = {
	"weapons/revolver_worldreload.wav",
};

static char g_RangedSound[][] = {
	"weapons/ambassador_shoot.wav",
};

//static float fl_PlayMusicSound[MAXENTITIES];
//static float fl_AlreadyStrippedMusic[MAXTF2PLAYERS];
//static float MoreGunTimer[MAXENTITIES];
//static float IGuessMoreGunNeedsAFloat[MAXENTITIES];
static float FinalGunTimer[MAXENTITIES];
static float f_BackToMeleeAnimation[MAXENTITIES];
static float MeleeAttackSpeed[MAXENTITIES];
static float FastAsHellKnife[MAXENTITIES];
static float RngTime[MAXENTITIES];
static float RngTimeTrue[MAXENTITIES];
static float TheExplosiveFart[MAXENTITIES];
static float DisableFakeUber[MAXENTITIES];
static bool BackToMeleeAnimation[MAXENTITIES];
static bool FinalGunReady[MAXENTITIES];
//static bool MoreGunReady[MAXENTITIES];
static bool FastAsHellKnifeReady[MAXENTITIES];
static bool TheExplosiveFartReady[MAXENTITIES];
static bool EnableTheRng[MAXENTITIES];
static bool Lifeloss[MAXENTITIES];
static bool FakeUber[MAXENTITIES];

public void Pablo_Gonzales_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedReloadSound));   i++) { PrecacheSound(g_RangedReloadSound[i]);   }
	for (int i = 0; i < (sizeof(g_RangedSound));   i++) { PrecacheSound(g_RangedSound[i]);   }
	PrecacheModel("models/player/spy.mdl");
	PrecacheSound("mvm/mvm_warning.wav");
	PrecacheSound("mvm/mvm_tank_end.wav");
	PrecacheSound("mvm/mvm_tank_deploy.wav");
	PrecacheSound("freak_fortress_2/pablonew/stabbed1.mp3");
	PrecacheSound("freak_fortress_2/pablonew/stabbed3.mp3");
	PrecacheSound("freak_fortress_2/pablonew/lostlife.mp3");
	PrecacheSound("freak_fortress_2/pablonew/hyperrage.mp3");
	PrecacheSound("freak_fortress_2/pablonew/bgm2.mp3");
	PrecacheSound("freak_fortress_2/pablonew/bgm3.mp3");
	//PrecacheSound("freak_fortress_2/pablonew/moregun.mp3");
}

methodmap Pablo_Gonzales < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CPablo_Gonzales::PlayIdleSound()");
		#endif
	}
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CPablo_Gonzales::PlayIdleAlertSound()");
		#endif
	}
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CPablo_Gonzales::PlayHurtSound()");
		#endif
	}
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CPablo_Gonzales::PlayDeathSound()");
		#endif
	}
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CPablo_Gonzales::PlayMeleeHitSound()");
		#endif
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CPablo_Gonzales::PlayMeleeHitSound()");
		#endif
	}
	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CPablo_Gonzales::PlayMeleeMissSound()");
		#endif
	}
	public void PlayRangedReloadSound() {
		EmitSoundToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CPablo_Gonzales::PlayRangedReloadSound()");
		#endif
	}
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedSound[GetRandomInt(0, sizeof(g_RangedSound) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CPablo_Gonzales::PlayRangedSound()");
		#endif
	}
	
	public Pablo_Gonzales(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		Pablo_Gonzales npc = view_as<Pablo_Gonzales>(CClotBody(vecPos, vecAng, "models/player/spy.mdl", "1.0", "300000", ally, false));
		
		i_NpcInternalId[npc.index] = PABLO_GONZALES;
		if(!b_IsAlliedNpc[npc.index])
		{
			RaidBossActive = EntRefToEntIndex(npc.index);
			for(int client_check=1; client_check<=MaxClients; client_check++)
			{
				if(IsClientInGame(client_check) && !IsFakeClient(client_check))
				{
					//LookAtTarget(client_check, npc.index);
					SetGlobalTransTarget(client_check);
					ShowGameText(client_check, "item_armor", 1, "%t", "Pablo Spawn Message");
				}
			}
			RaidModeTime = GetGameTime(npc.index) + 200.0;
		}
		i_ExplosiveProjectileHexArray[npc.index] = EP_NO_KNOCKBACK;
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_bThisNpcIsABoss = true;
		
		FinalGunReady[npc.index] = false;
		//MoreGunReady[npc.index] = false;
		FastAsHellKnifeReady[npc.index] = false;
		BackToMeleeAnimation[npc.index] = false;
		TheExplosiveFartReady[npc.index] = false;
		EnableTheRng[npc.index] = false;
		Lifeloss[npc.index] = false;
		FakeUber[npc.index] = false;
		npc.m_fbGunout = false;
		npc.Anger = false;
		
		npc.m_flSpeed = 300.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		RngTime[npc.index] = GetGameTime(npc.index) + 20.0;
		RngTimeTrue[npc.index] = GetGameTime(npc.index) + 29.0 ;//forced to be like this this is more of a fail lazy attempt from almost a year ago and i am still lazy
		FinalGunTimer[npc.index] =  GetGameTime(npc.index) + 9999.0;
		//MoreGunTimer[npc.index] = 9999.0 + GetGameTime(npc.index);
		FastAsHellKnife[npc.index] = GetGameTime(npc.index) + 9999.0;
		TheExplosiveFart[npc.index] = GetGameTime(npc.index) + 9999.0;
		DisableFakeUber[npc.index] = GetGameTime(npc.index) + 9999.0;
		MeleeAttackSpeed[npc.index] = 0.85;
		//IGuessMoreGunNeedsAFloat[npc.index] = 0.15;
		npc.m_iAttacksTillReload = 25;
		//npc.m_flPlayMusicSound = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/player/items/all_class/ghostly_gibus_spy.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_knife/c_knife.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		SetEntityRenderMode(npc.m_iWearable2, RENDER_NORMAL);
		SetEntityRenderColor(npc.m_iWearable2, 255, 255, 255, 255);
		
		npc.m_iWearable3 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_ambassador/c_ambassador.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		SetEntityRenderMode(npc.m_iWearable3, RENDER_NORMAL);
		SetEntityRenderColor(npc.m_iWearable3, 255, 255, 255, 255);
		
		npc.m_iWearable4 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_letranger/c_letranger.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		SetEntityRenderMode(npc.m_iWearable4, RENDER_NORMAL);
		SetEntityRenderColor(npc.m_iWearable4, 255, 255, 255, 255);
		
		AcceptEntityInput(npc.m_iWearable3, "Disable");
		AcceptEntityInput(npc.m_iWearable4, "Disable");
		
		//if(Lifeloss[npc.index])
		//{
		//	for(int client_clear=1; client_clear<=MaxClients; client_clear++)
		//	{
		//		fl_AlreadyStrippedMusic[client_clear] = 0.0; //reset to 0
		//	}
		//}
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		SDKHook(npc.index, SDKHook_OnTakeDamage, Pablo_Gonzales_OnTakeDamage);
		SDKHook(npc.index, SDKHook_Think, Pablo_Gonzales_ClotThink);
		SDKHook(npc.index, SDKHook_OnTakeDamagePost, Pablo_Gonzales_ClotDamaged_Post);
		
		npc.StartPathing();
		
		return npc;
	}
}

//TODO 
//Rewrite
public void Pablo_Gonzales_ClotThink(int iNPC)
{
	Pablo_Gonzales npc = view_as<Pablo_Gonzales>(iNPC);
	if(!b_IsAlliedNpc[npc.index])
	{
		if(RaidModeTime < GetGameTime())
		{
			int entity = CreateEntityByName("game_round_win"); //You loose.
			DispatchKeyValue(entity, "force_map_reset", "1");
			SetEntProp(entity, Prop_Data, "m_iTeamNum", TFTeam_Blue);
			Music_Stop_All_Blitzkrieg(entity);
			DispatchSpawn(entity);
			AcceptEntityInput(entity, "RoundWin");
			Music_RoundEnd(entity);
			RaidBossActive = INVALID_ENT_REFERENCE;
			SDKUnhook(npc.index, SDKHook_Think, Pablo_Gonzales_ClotThink);
		}
	}
	
//	PrintToChatAll("%.f",GetEntPropFloat(view_as<int>(iNPC), Prop_Data, "m_speed"));
	npc.Update();
	
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.m_blPlayHurtAnimation = false;
		npc.AddGesture("ACT_GESTURE_FLINCH_HEAD", false);
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	
	if(RngTimeTrue[npc.index] <= GetGameTime(npc.index) && !EnableTheRng[npc.index])
	{
		EnableTheRng[npc.index] = true;
	}
	
	if(RngTime[npc.index] <= GetGameTime(npc.index) && !FinalGunReady[npc.index] && !FastAsHellKnifeReady[npc.index] && !TheExplosiveFartReady[npc.index] && EnableTheRng[npc.index])
	{
		EnableTheRng[npc.index] = false;
		RngTimeTrue[npc.index] = GetGameTime(npc.index) + 29.0;
		RngTime[npc.index] = GetGameTime(npc.index) + 2999.0;//man i hate this
		switch(GetRandomInt(1, 3))
		{
			case 1:
			{
				CPrintToChatAll("{crimson}WARNING: {default}Pablo gained {red}FINAL GUN!");
				EmitSoundToAll("mvm/mvm_warning.wav", _, _, _, _, 1.0);
				EmitSoundToAll("freak_fortress_2/pablonew/finalgun.mp3", _, _, _, _, 1.0);
				FinalGunTimer[npc.index] = GetGameTime(npc.index) + 3.1;
				npc.m_iAttacksTillReload = 1;
				for(int client = 1; client <= MaxClients; client++)
				{
					if(IsValidClient(client))
					{
						SetHudTextParams(-1.0, 0.25, 3.01, 34, 139, 34, 255);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client, SyncHud_Notifaction, "WARNING!\nPablo Gained FINAL GUN!");
					}
				}//DO NOT PUT ANYTHING UNDER IT, IT WONT PLAY ANYTHING BELOW
			}
			case 2:
			{
				CPrintToChatAll("{crimson}WARNING: {default}Pablo gained {yellow}Fast {red}BUTTERKNIFE!");
				EmitSoundToAll("mvm/mvm_tank_end.wav", _, _, _, _, 1.0);
				EmitSoundToAll("freak_fortress_2/pablonew/power.mp3", _, _, _, _, 1.0);
				FastAsHellKnife[npc.index] = GetGameTime(npc.index) + 2.1;
				for(int client = 1; client <= MaxClients; client++)
				{
					if(IsValidClient(client))
					{
						SetHudTextParams(-1.0, 0.25, 3.01, 34, 139, 34, 255);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client, SyncHud_Notifaction, "WARNING!\nPablo Gained Fast BUTTERKNIFE!");
					}
				}//DO NOT PUT ANYTHING UNDER IT, IT WONT PLAY ANYTHING BELOW
			}
			case 3:
			{
				CPrintToChatAll("{crimson}WARNING: {default}Pablo is about to {red}EXPLODE the Area.");
				EmitSoundToAll("mvm/mvm_warning.wav", _, _, _, _, 1.0);
				TheExplosiveFart[npc.index] = GetGameTime(npc.index) + 7.1;
				for(int client = 1; client <= MaxClients; client++)
				{
					if(IsValidClient(client))
					{
						SetHudTextParams(-1.0, 0.25, 3.01, 34, 139, 34, 255);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client, SyncHud_Notifaction, "WARNING!\nPablo is about to EXPLODE the Area.");
						SetVariantString("HalloweenLongFall");
						AcceptEntityInput(client, "SpeakResponseConcept");
					}
				}//DO NOT PUT ANYTHING UNDER IT, IT WONT PLAY ANYTHING BELOW
			}
			/*case 4:
			{
				CPrintToChatAll("{crimson}WARNING: {default}Pablo gained {yellow}More Gun.");
				EmitSoundToAll("mvm/mvm_tank_end.wav", _, _, _, _, 1.0)
				EmitSoundToAll("freak_fortress_2/pablonew/moregun.mp3", _, _, _, _, 1.0)
				//npc.m_iAttacksTillReload = 25;
				MoreGunTimer[npc.index] = GetGameTime(npc.index) + 2.1;
				for(int client = 1; client <= MaxClients; client++)
				{
					if(IsValidClient(client))
					{
						SetHudTextParams(-1.0, 0.25, 3.01, 34, 139, 34, 255);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client, SyncHud_Notifaction, "WARNING!\nPablo Gained More Gun.!");
					}
				}//DO NOT PUT ANYTHING UNDER IT, IT WONT PLAY ANYTHING BELOW
			}*/
		}
	}
	if(f_BackToMeleeAnimation[npc.index] <= GetGameTime(npc.index) && BackToMeleeAnimation[npc.index])
	{
		if(npc.m_iChanged_WalkCycle != 2)
		{
			npc.m_iChanged_WalkCycle = 2;
			int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
			if(iActivity > 0) npc.StartActivity(iActivity);
			AcceptEntityInput(npc.m_iWearable2, "Enable");
			AcceptEntityInput(npc.m_iWearable3, "Disable");
			AcceptEntityInput(npc.m_iWearable4, "Disable");
		}
		BackToMeleeAnimation[npc.index] = false;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		//float targPos[3];
		//float chargerPos[3];
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + 1.0;
		npc.StartPathing();
		//if(Lifeloss[npc.index])
		//{
		//	for(int client=1; client<=MaxClients; client++)
		//	{
		//		if(IsClientInGame(client))
		//		{
		//			GetClientAbsOrigin(client, targPos);
		//			if (GetVectorDistance(chargerPos, targPos, true) <= 4000000) // 1500 range
		//			{
		//				if(fl_AlreadyStrippedMusic[client] < GetEngineTime())
		//				{
		//					Music_Stop_All(client); //This is actually more expensive then i thought.
		//					Music_Stop_All_Wave_Music(client); //This is actually more expensive then i thought.
		//				}
		//				SetMusicTimer(client, GetTime() + 5);
		//				fl_AlreadyStrippedMusic[client] = GetEngineTime() + 5.0;
		//			}
		//		}
		//	}
		//}
	}
	
	int closest = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, closest))
	{
		float vecTarget[3]; vecTarget = WorldSpaceCenter(closest);
		
		float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
		
		if(flDistanceToTarget < npc.GetLeadRadius()) //Predict their pos.
		{
			float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, closest);
			PF_SetGoalVector(npc.index, vPredictedPos);
		}
		else
		{
			PF_SetGoalEntity(npc.index, closest);
		}
		if(FinalGunTimer[npc.index] <= GetGameTime(npc.index) && !FinalGunReady[npc.index])
		{
			FinalGunReady[npc.index] = true;
			FinalGunTimer[npc.index] = GetGameTime(npc.index) + 3.0;
			if(npc.m_iChanged_WalkCycle != 1)
			{
				npc.m_iChanged_WalkCycle = 1;
				AcceptEntityInput(npc.m_iWearable2, "Disable");
				AcceptEntityInput(npc.m_iWearable3, "Enable");
				int iActivity_melee = npc.LookupActivity("ACT_MP_RUN_SECONDARY");
				if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
			}
			if(npc.m_flNextRangedAttack < GetGameTime(npc.index) && flDistanceToTarget < 1240000 && npc.m_flReloadDelay < GetGameTime(npc.index))
			{
				int target;
			
				target = Can_I_See_Enemy(npc.index, closest);
				
				npc.m_iAttacksTillReload -= 1;
				
				if(!IsValidEnemy(npc.index, target))
				{
					//if (!npc.m_bmovedelay)
					//{
					//	npc.m_bmovedelay = true;
					//	npc.m_flSpeed = 180.0;
					//}
					npc.StartPathing();
					
					//npc.m_fbGunout = false;
				}
				else
				{
					npc.m_fbGunout = true;
					
					npc.m_bmovedelay = false;
					
					npc.FaceTowards(vecTarget, 20000.0);
					
					float vecSpread = 0.1;
				
					float eyePitch[3];
					GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
					
					float x, y;
					x = GetRandomFloat( -0.15, 0.15 ) + GetRandomFloat( -0.15, 0.15 );
					y = GetRandomFloat( -0.15, 0.15 ) + GetRandomFloat( -0.15, 0.15 );
					
					float vecDirShooting[3], vecRight[3], vecUp[3];
					
					vecTarget[2] += 15.0;
					MakeVectorFromPoints(WorldSpaceCenter(npc.index), vecTarget, vecDirShooting);
					GetVectorAngles(vecDirShooting, vecDirShooting);
					vecDirShooting[1] = eyePitch[1];
					GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
				
					npc.m_flNextRangedAttack = GetGameTime(npc.index) + 1.0;
					
					npc.m_iAttacksTillReload -= 1;
					
					if(npc.m_iAttacksTillReload == 0)
					{
						npc.AddGesture("ACT_MP_RELOAD_STAND_SECONDARY");
						npc.m_flReloadDelay = GetGameTime(npc.index) + 1.0;
						npc.m_iAttacksTillReload = 1;
						npc.PlayRangedReloadSound();
					}
					
					npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY");
					float vecDir[3];
					vecDir[0] = vecDirShooting[0] + x * vecSpread * vecRight[0] + y * vecSpread * vecUp[0]; 
					vecDir[1] = vecDirShooting[1] + x * vecSpread * vecRight[1] + y * vecSpread * vecUp[1]; 
					vecDir[2] = vecDirShooting[2] + x * vecSpread * vecRight[2] + y * vecSpread * vecUp[2]; 
					NormalizeVector(vecDir, vecDir);
					
					if(EscapeModeForNpc)
					{
						FireBullet(npc.index, npc.m_iWearable3, WorldSpaceCenter(npc.index), vecDir, 10.0, 9000.0, DMG_BULLET, "bullet_tracer01_red");
					}
					else
					{
						FireBullet(npc.index, npc.m_iWearable3, WorldSpaceCenter(npc.index), vecDir, 300.0, 9000.0, DMG_BULLET, "bullet_tracer01_red");
					}
					npc.PlayRangedSound();
				}
			}
			//Target close enough to hit
			if(flDistanceToTarget > 10000 && npc.m_flReloadDelay < GetGameTime(npc.index))
			{
				npc.StartPathing();
				
				//npc.m_fbGunout = false;
				//Look at target so we hit.
				//npc.FaceTowards(vecTarget, 5000.0);
			}
		}
		if(FinalGunTimer[npc.index] <= GetGameTime(npc.index) && FinalGunReady[npc.index])
		{
			FinalGunReady[npc.index] = false;
			RngTime[npc.index] = GetGameTime(npc.index) + 20.0;
			FinalGunTimer[npc.index] = GetGameTime(npc.index) + 9999.0;
			BackToMeleeAnimation[npc.index] = true;
			f_BackToMeleeAnimation[npc.index] = 0.1;
		}
		else if(!FinalGunReady[npc.index])
		{
			if(flDistanceToTarget < 45000 || npc.m_flAttackHappenswillhappen) //Target close enough to hit
			{
				//npc.FaceTowards(vecTarget, 20000.0); //Look at target so we hit.
				if(npc.m_flNextMeleeAttack < GetGameTime(npc.index))
				{
					if(!npc.m_flAttackHappenswillhappen)//Play attack anims
					{
						npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
						//npc.PlayMeleeSound();
						npc.m_flAttackHappens = 0.00;
						npc.m_flAttackHappens_bullshit = GetGameTime(npc.index) + MeleeAttackSpeed[npc.index];
						npc.m_flAttackHappenswillhappen = true;
					}
					//Can we attack right now?
					if(npc.m_flAttackHappens < GetGameTime(npc.index) && npc.m_flAttackHappens_bullshit >= GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
					{
						Handle swingTrace;
						npc.FaceTowards(vecTarget, 20000.0);
						if(npc.DoSwingTrace(swingTrace, closest))
						{
							int target = TR_GetEntityIndex(swingTrace);	
							float vecHit[3];
							TR_GetEndPosition(vecHit, swingTrace);
							if(target > 0)
							{
								if(EscapeModeForNpc)
								{
									if(target <= MaxClients)
										SDKHooks_TakeDamage(target, npc.index, npc.index, 160.0, DMG_CLUB, -1, _, vecHit);
									else
										SDKHooks_TakeDamage(target, npc.index, npc.index, 7000.0, DMG_CLUB, -1, _, vecHit);
								}
								else
								{
									if(target <= MaxClients)
										SDKHooks_TakeDamage(target, npc.index, npc.index, 210.0, DMG_CLUB, -1, _, vecHit);
									else
										SDKHooks_TakeDamage(target, npc.index, npc.index, 9000.0, DMG_CLUB, -1, _, vecHit);					
								}
								npc.PlayMeleeSound();
								//npc.PlayMeleeHitSound();
							}
							else
							{
								npc.PlayMeleeMissSound();
							}
						}
						delete swingTrace;
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + MeleeAttackSpeed[npc.index];
						npc.m_flAttackHappenswillhappen = false;
					}
					else if(npc.m_flAttackHappens_bullshit < GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
					{
						npc.m_flAttackHappenswillhappen = false;
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + MeleeAttackSpeed[npc.index];
					}
				}
			}
		}
		if(FastAsHellKnife[npc.index] <= GetGameTime(npc.index) && !FastAsHellKnifeReady[npc.index] && !FinalGunReady[npc.index] && !Lifeloss[npc.index])
		{
			MeleeAttackSpeed[npc.index] = 0.1;
			FastAsHellKnifeReady[npc.index] = true;
			FastAsHellKnife[npc.index] = GetGameTime(npc.index) + 5.0;
			npc.m_flSpeed = 400.0;
		}
		if(FastAsHellKnife[npc.index] <= GetGameTime(npc.index) && !FastAsHellKnifeReady[npc.index] && !FinalGunReady[npc.index] && Lifeloss[npc.index])
		{
			MeleeAttackSpeed[npc.index] = 0.1;
			FastAsHellKnifeReady[npc.index] = true;
			FastAsHellKnife[npc.index] = GetGameTime(npc.index) + 9.5;
			npc.m_flSpeed = 450.0;
			//switch(GetRandomInt(1, 3)) //after the timescale fix this doesn't really work
			//{
			//	case 1:
			//	{
			//		cvarTimeScale.SetFloat(0.1);
			//		CreateTimer(0.5, SetTimeBack);//can be reenabled might do the lag feeling tho
			//		npc.m_flSpeed = 650.0;
			//	}
			//	case 2:
			//	{
			//		npc.m_flSpeed = 400.0;
			//	}
			//}
		}
		if(FastAsHellKnife[npc.index] <= GetGameTime(npc.index) && FastAsHellKnifeReady[npc.index])
		{
			FastAsHellKnifeReady[npc.index] = false;
			MeleeAttackSpeed[npc.index] = 0.85;
			RngTime[npc.index] = GetGameTime(npc.index) + 20.0;
			FastAsHellKnife[npc.index] = GetGameTime(npc.index) + 9999.0;
			npc.m_flSpeed = 300.0;
		}
		if(TheExplosiveFart[npc.index] <= GetGameTime(npc.index) && !TheExplosiveFartReady[npc.index])
		{
			TheExplosiveFart[npc.index] = GetGameTime(npc.index) + 2.0;
			TheExplosiveFartReady[npc.index] = true;
			int entity = EntRefToEntIndex(iNPC);
			float pos[3];
			GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
			Explode_Logic_Custom(300.0, entity, entity, -1, pos, 400.0, _, 0.8, true);
			npc.DispatchParticleEffect(npc.index, "skull_island_explosion", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("head"), PATTACH_POINT_FOLLOW, true);
		}
		if(TheExplosiveFart[npc.index] <= GetGameTime(npc.index) && TheExplosiveFartReady[npc.index])
		{
			RngTime[npc.index] = GetGameTime(npc.index) + 20.0;
			TheExplosiveFartReady[npc.index] = false;
			TheExplosiveFart[npc.index] = GetGameTime(npc.index) + 9999.0;
		}
		if(DisableFakeUber[npc.index] <= GetGameTime(npc.index) && FakeUber[npc.index] || Lifeloss[npc.index])
		{
			int skin = 1;
			SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
			FakeUber[npc.index] = false;
			npc.m_flRangedArmor = 1.0;
			npc.m_flMeleeArmor = 1.0;
		}
	}
	else
	{
		PF_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleSound();
}

public Action Set_Pablo_Gonzales_HP(Handle timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(entity>MaxClients && IsValidEntity(entity))
	{
		SetEntProp(entity, Prop_Data, "m_iHealth", (GetEntProp(entity, Prop_Data, "m_iMaxHealth") / 2));
	}
	return Plugin_Stop;
}

public void Pablo_Gonzales_ClotDamaged_Post(int iNPC, int attacker, int inflictor, float damage, int damagetype)
{
	Pablo_Gonzales npc = view_as<Pablo_Gonzales>(iNPC);
	if((GetEntProp(npc.index, Prop_Data, "m_iMaxHealth") / 2 )>= GetEntProp(npc.index, Prop_Data, "m_iHealth") && !npc.Anger) //npc.Anger after half hp/400 hp
	{
		npc.Anger = true; //	>:( your mother
		//npc.PlayMusicSound(); //doesn't work well with the other music :/
		//int client;
		//Music_Stop_All_Wave_Music(client);
		EmitSoundToAll("freak_fortress_2/pablonew/lostlife.mp3", _, _, _, _, 1.0);
		FakeUber[npc.index] = true;
		int skin = 3;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		DisableFakeUber[npc.index] = GetGameTime(npc.index) + 11.0;
		npc.m_flSpeed = 310.0;
		npc.m_flRangedArmor = 0.0;
		npc.m_flMeleeArmor = 0.0;
	}
	/*//Gonna bother later fixing it
	int weapon = GetEntPropEnt(attacker, Prop_Send, "m_hActiveWeapon");
	char classname[32];
	GetEntityClassname(weapon, classname, sizeof(classname));
	if(!StrContains(classname, "tf_weapon_knife", false))
	{
		if(damagetype & DMG_CLUB) //Use dmg slash for any npc that shouldnt be scaled.
		{
			if(IsBehindAndFacingTarget(attacker, iNPC))
			{
				int melee = GetIndexOfWeaponSlot(attacker, TFWeaponSlot_Melee);
				if(melee != 4 && melee != 1003)
				{
					int	entity = iNPC;
					int closest = attacker;
					if(IsValidEntity(entity) && entity>MaxClients)
					{
						if(closest > 0) 
						{
							if(closest <= MaxClients)
								//SDKHooks_TakeDamage(closest, npc.index, npc.index, 5.0 * RaidModeScaling, DMG_CLUB, -1, _);
								SDKHooks_TakeDamage(closest, npc.index, npc.index, 90.0, DMG_CLUB, -1, _);
							else
								//SDKHooks_TakeDamage(closest, npc.index, npc.index, 7.0 * RaidModeScaling, DMG_CLUB, -1, _);
								SDKHooks_TakeDamage(closest, npc.index, npc.index, 110.0, DMG_CLUB, -1, _);
							float pos[3];
							GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
							makeexplosion(-1, -1, pos, "", 0, 150);
							npc.DispatchParticleEffect(npc.index, "skull_island_explosion", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("head"), PATTACH_POINT_FOLLOW, true);
						} 
					}
					switch(GetRandomInt(1, 2))
					{
						case 1:
						{
							EmitSoundToAll("freak_fortress_2/pablonew/stabbed1.mp3", attacker, _, _, _, 1.0);
						}
						case 2:
						{
							EmitSoundToAll("freak_fortress_2/pablonew/stabbed3.mp3", attacker, _, _, _, 1.0);
						}
					}
				}
			}
		}
	}*/
}

public Action Pablo_Gonzales_OnTakeDamage(int iNPC, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;

	Pablo_Gonzales npc = view_as<Pablo_Gonzales>(iNPC);
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void Pablo_Gonzales_NPCDeath(int entity)
{
	Pablo_Gonzales npc = view_as<Pablo_Gonzales>(entity);
	npc.PlayDeathSound();
	//Music_Stop_All_Pablo(entity);
	//SDKHooks_TakeDamage(entity, 0, 0, 999999999.0, DMG_GENERIC);
	SDKUnhook(entity, SDKHook_OnTakeDamage, Pablo_Gonzales_OnTakeDamage);
	SDKUnhook(entity, SDKHook_OnTakeDamagePost, Pablo_Gonzales_ClotDamaged_Post);
	SDKUnhook(entity, SDKHook_Think, Pablo_Gonzales_ClotThink);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	//AcceptEntityInput(npc.index, "KillHierarchy");
}

//void Music_Stop_All_Pablo(int entity)
//{
//	StopSound(entity, SNDCHAN_AUTO, "freak_fortress_2/pablonew/pablo_lifeloss.mp3");
//	StopSound(entity, SNDCHAN_AUTO, "freak_fortress_2/pablonew/pablo_lifeloss.mp3");
//	StopSound(entity, SNDCHAN_AUTO, "freak_fortress_2/pablonew/pablo_lifeloss.mp3");
//	StopSound(entity, SNDCHAN_AUTO, "freak_fortress_2/pablonew/pablo_lifeloss.mp3");
//	StopSound(entity, SNDCHAN_AUTO, "freak_fortress_2/pablonew/pablo_lifeloss.mp3");
//	StopSound(entity, SNDCHAN_AUTO, "freak_fortress_2/pablonew/pablo_lifeloss.mp3");
//	StopSound(entity, SNDCHAN_AUTO, "freak_fortress_2/pablonew/pablo_lifeloss.mp3");
//	StopSound(entity, SNDCHAN_AUTO, "freak_fortress_2/pablonew/pablo_lifeloss.mp3");
//}
//void Music_Stop_All_Wave_Music(int entity)
//{
//	StopSound(entity, SNDCHAN_AUTO, "freak_fortress_2/pablonew/bgm3.mp3");
//	StopSound(entity, SNDCHAN_AUTO, "freak_fortress_2/pablonew/bgm3.mp3");
//	StopSound(entity, SNDCHAN_AUTO, "freak_fortress_2/pablonew/bgm3.mp3");
//	StopSound(entity, SNDCHAN_AUTO, "freak_fortress_2/pablonew/bgm3.mp3");
//	StopSound(entity, SNDCHAN_AUTO, "freak_fortress_2/pablonew/bgm2.mp3");
//	StopSound(entity, SNDCHAN_AUTO, "freak_fortress_2/pablonew/bgm2.mp3");
//	StopSound(entity, SNDCHAN_AUTO, "freak_fortress_2/pablonew/bgm2.mp3");
//	StopSound(entity, SNDCHAN_AUTO, "freak_fortress_2/pablonew/bgm2.mp3");
//}