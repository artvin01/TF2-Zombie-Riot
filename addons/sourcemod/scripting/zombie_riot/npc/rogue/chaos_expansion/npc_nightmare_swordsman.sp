#pragma semicolon 1
#pragma newdecls required


static char g_DeathSounds[][] = {
	"npc/combine_soldier/die1.wav",
	"npc/combine_soldier/die2.wav",
	"npc/combine_soldier/die3.wav",
};

static char g_HurtSounds[][] = {
	"npc/combine_soldier/pain1.wav",
	"npc/combine_soldier/pain2.wav",
	"npc/combine_soldier/pain3.wav",
};

static char g_IdleSounds[][] = {
	"npc/combine_soldier/vo/alert1.wav",
	"npc/combine_soldier/vo/bouncerbouncer.wav",
	"npc/combine_soldier/vo/boomer.wav",
	"npc/combine_soldier/vo/contactconfim.wav",
};

static char g_IdleAlertedSounds[][] = {
	"npc/combine_soldier/vo/alert1.wav",
	"npc/combine_soldier/vo/bouncerbouncer.wav",
	"npc/combine_soldier/vo/boomer.wav",
	"npc/combine_soldier/vo/contactconfim.wav",
};
static char g_MeleeHitSounds[][] = {
	"weapons/halloween_boss/knight_axe_hit.wav",
};

static char g_MeleeAttackSounds[][] = {
	"weapons/demo_sword_swing1.wav",
	"weapons/demo_sword_swing2.wav",
	"weapons/demo_sword_swing3.wav",
};


static char g_RangedAttackSounds[][] = {
	"weapons/ar2/fire1.wav",
};

static char g_RangedAttackSoundsSecondary[][] = {
	"weapons/physcannon/energy_sing_explosion2.wav",
};

static char g_RangedReloadSound[][] = {
	"weapons/ar2/npc_ar2_reload.wav",
};

static char g_MeleeMissSounds[][] = {
	"weapons/cbar_miss1.wav",
};

public void NightmareSwordsman_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds));   i++) { PrecacheSound(g_RangedAttackSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedReloadSound));   i++) { PrecacheSound(g_RangedReloadSound[i]);   }
	for (int i = 0; i < (sizeof(g_RangedAttackSoundsSecondary));   i++) { PrecacheSound(g_RangedAttackSoundsSecondary[i]);   }
	
	PrecacheModel("models/props_wasteland/rockgranite03b.mdl");
	PrecacheModel("models/weapons/w_bullet.mdl");
	PrecacheModel("models/weapons/w_grenade.mdl");
	
	PrecacheSound("ambient/explosions/citadel_end_explosion2.wav",true);
	PrecacheSound("ambient/explosions/citadel_end_explosion1.wav",true);
	PrecacheSound("ambient/energy/weld1.wav",true);
	PrecacheSound("ambient/halloween/mysterious_perc_01.wav",true);
	
	PrecacheSound("player/flow.wav");
	PrecacheModel("models/effects/combineball.mdl", true);
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Xeno Seaborn W.F. Chaos Voided Acclaimed Swordsman The First");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_nightmare_swordsman");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = -1;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	data.Precache = ClotPrecacheSea;
	NPC_Add(data);
}

static void ClotPrecacheSea()
{
	PrecacheSoundCustom("#zombiesurvival/medieval_raid/special_mutation/incomming_boss_wait_scary.mp3");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return NightmareSwordsman(vecPos, vecAng, team);
}

methodmap NightmareSwordsman < CClotBody
{
	property float f_CaptinoAgentusTeleport
	{
		public get()							{ return fl_AttackHappensMaximum[this.index]; }
		public set(float TempValueForProperty) 	{ fl_AttackHappensMaximum[this.index] = TempValueForProperty; }
	}
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
		

	}
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		
		
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		
	}
	
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		

	}
	public void PlayRangedReloadSound() {
		EmitSoundToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		

	}
	public void PlayRangedAttackSecondarySound() {
		EmitSoundToAll(g_RangedAttackSoundsSecondary[GetRandomInt(0, sizeof(g_RangedAttackSoundsSecondary) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		

	}
	
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayTeleportSound() 
	{
		EmitCustomToAll("zombiesurvival/internius/blinkarrival.wav", this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME * 2.0);
	}
	
	property float m_flBackupDespawnEmergency
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	
	public NightmareSwordsman(float vecPos[3], float vecAng[3], int ally)
	{
		NightmareSwordsman npc = view_as<NightmareSwordsman>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", "1500", ally));
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");				
		i_NpcWeight[npc.index] = 999;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_RUN");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;		
		
		float TimeUntillOver = 3.0;
		TimeUntillOver *= float(CountPlayersOnRed());
		npc.m_flNextMeleeAttack = 0.0;
		MusicEnum music;
		strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/medieval_raid/special_mutation/incomming_boss_wait_scary.mp3");
		music.Time = 30;
		music.Volume = 1.0;
		music.Custom = true;
		strcopy(music.Name, sizeof(music.Name), "Howilng Emptiness");
		strcopy(music.Artist, sizeof(music.Artist), "....");
		Music_SetRaidMusic(music);

		if(TimeUntillOver <= 10.0)
			TimeUntillOver = 10.0;

		if(TimeUntillOver >= 60.0)
			TimeUntillOver = 60.0;
		
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client))
			{
				SetMusicTimer(client, GetTime());
			}
		}

		func_NPCDeath[npc.index] = NightmareSwordsman_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = NightmareSwordsman_OnTakeDamage;
		func_NPCThink[npc.index] = NightmareSwordsman_ClotThink;
		
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		npc.m_iState = 0;
		npc.m_flSpeed = 500.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_fbRangedSpecialOn = false;
		fl_TotalArmor[npc.index] = 0.25;
		if(!IsValidEntity(RaidBossActive))
		{
			RaidBossActive = EntIndexToEntRef(npc.index);
			RaidModeTime = GetGameTime(npc.index) + TimeUntillOver;
			RaidModeScaling = 0.0;
			RaidAllowsBuildings = true;
		}
		b_thisNpcIsARaid[npc.index] = true;
		b_thisNpcIsABoss[npc.index] = true;
		npc.m_flBackupDespawnEmergency = GetGameTime() + TimeUntillOver;

		if(FogEntity != INVALID_ENT_REFERENCE)
		{
			int entity = EntRefToEntIndex(FogEntity);
			if(entity > MaxClients)
				RemoveEntity(entity);
			FogEntity = INVALID_ENT_REFERENCE;
		}

		int entity = CreateEntityByName("env_fog_controller");
		if(entity != -1)
		{
			DispatchKeyValue(entity, "fogblend", "2");
			DispatchKeyValue(entity, "fogcolor", "15 15 15 255");
			DispatchKeyValue(entity, "fogcolor2", "15 15 15 255");
			DispatchKeyValueFloat(entity, "fogstart", 305.0);
			DispatchKeyValueFloat(entity, "fogend", 500.0);
			DispatchKeyValueFloat(entity, "fogmaxdensity", 1.0);

			DispatchKeyValue(entity, "targetname", "rpg_fortress_envfog");
			DispatchKeyValue(entity, "fogenable", "1");
			DispatchKeyValue(entity, "spawnflags", "1");
			DispatchSpawn(entity);
			AcceptEntityInput(entity, "TurnOn");

			FogEntity = EntIndexToEntRef(entity);
			
			for(int client1 = 1; client1 <= MaxClients; client1++)
			{
				if(IsClientInGame(client1))
				{
					SetVariantString("rpg_fortress_envfog");
					AcceptEntityInput(client1, "SetFogController");
				}
			}
		}
		for(int client1 = 1; client1 <= MaxClients; client1++)
		{
			if(IsClientInGame(client1))
			{
				ApplyStatusEffect(npc.index, client1, "Nightmare Terror", TimeUntillOver);
			}
		}
		
		CPrintToChatAll("{crimson}???{default}: You.");

		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_claymore/c_claymore.mdl");
		SetVariantString("0.8");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("partyhat", "models/workshop/player/items/engineer/spr17_flash_of_inspiration/spr17_flash_of_inspiration.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		npc.m_iWearable3 = npc.EquipItem("partyhat", "models/workshop_partner/player/items/pyro/hero_academy_pyro/hero_academy_pyro.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 0, 0, 0, 125);
		SetEntityRenderFx(npc.index, RENDERFX_PULSE_FAST_WIDER);

		SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable1, 0, 0, 0, 125);
		SetEntityRenderFx(npc.m_iWearable2, RENDERFX_PULSE_FAST_WIDER);

		SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable2, 0, 0, 0, 125);
		SetEntityRenderFx(npc.m_iWearable2, RENDERFX_PULSE_FAST_WIDER);

		SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable3, 0, 0, 0, 125);
		SetEntityRenderFx(npc.m_iWearable3, RENDERFX_PULSE_FAST_WIDER);
		
		float flPos[3], flAng[3];
				
			
		b_NoHealthbar[npc.index] = true;

		npc.GetAttachment("eyes", flPos, flAng);
		npc.m_iWearable4 = ParticleEffectAt_Parent(flPos, "unusual_smoking", npc.index, "eyes", {0.0,0.0,0.0});
		npc.m_iWearable5 = ParticleEffectAt_Parent(flPos, "unusual_psychic_eye_white_glow", npc.index, "eyes", {0.0,0.0,-15.0});
		npc.StartPathing();
		
		
		return npc;
	}
	
	
}


public void NightmareSwordsman_ClotThink(int iNPC)
{
	NightmareSwordsman npc = view_as<NightmareSwordsman>(iNPC);
	
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();	

	if((RaidModeTime < GetGameTime() || npc.m_flBackupDespawnEmergency < GetGameTime()))
	{
		CPrintToChatAll("{crimson}The nightmare fades.");
		RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
		RaidMusicSpecial1.Clear();
		return;
	}
	float TrueArmor = 1.0;
	TrueArmor *= 0.25;
	if(!NpcStats_IsEnemySilenced(npc.index))
	{
		if(npc.m_flNextRangedSpecialAttack)
			TrueArmor *= 0.15;
	}

	fl_TotalArmor[npc.index] = TrueArmor;

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_GESTURE_FLINCH_STOMACH", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;
	
	if(npc.m_flNextRangedSpecialAttack)
	{
		if(IsValidEnemy(npc.index, PrimaryThreatIndex))
		{
			float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
			npc.FaceTowards(vecTarget, 20000.0);
		}
		if(npc.m_flRangedSpecialDelay < gameTime)
		{
			if(IsValidEnemy(npc.index, PrimaryThreatIndex))
			{
				float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
				npc.FaceTowards(vecTarget, 20000.0);
				npc.PlayRangedAttackSecondarySound();
				
				float vecSpread = 0.1;
				
				npc.FaceTowards(vecTarget, 20000.0);
				
				float eyePitch[3];
				GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);

				float x, y;
				
				float vecDirShooting[3], vecRight[3], vecUp[3];

				vecTarget[2] += 15.0;
				float SelfVecPos[3]; WorldSpaceCenter(npc.index, SelfVecPos);
				MakeVectorFromPoints(SelfVecPos, vecTarget, vecDirShooting);
				GetVectorAngles(vecDirShooting, vecDirShooting);
				vecDirShooting[1] = eyePitch[1];
				GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
				
				//add the spray
				float vecDir[3];
				vecDir[0] = vecDirShooting[0] + x * vecSpread * vecRight[0] + y * vecSpread * vecUp[0]; 
				vecDir[1] = vecDirShooting[1] + x * vecSpread * vecRight[1] + y * vecSpread * vecUp[1]; 
				vecDir[2] = vecDirShooting[2] + x * vecSpread * vecRight[2] + y * vecSpread * vecUp[2]; 
				NormalizeVector(vecDir, vecDir);
				float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
				npc.DispatchParticleEffect(npc.index, "mvm_soldier_shockwave", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("anim_attachment_LH"), PATTACH_POINT_FOLLOW, true);
				int HitEnemy = FireBullet(npc.index, npc.index, WorldSpaceVec, vecDir, 1000.0, 400.0, DMG_CLUB, "bullet_tracer02_blue", _,_,"anim_attachment_LH");
				if(IsValidEnemy(npc.index, HitEnemy))
				{
					//I hit them, time to destroy.
					float vPredictedPos[3];
					PredictSubjectPosition(npc, HitEnemy,_,_, vPredictedPos);
					vPredictedPos = GetBehindTarget(HitEnemy, 30.0 ,vPredictedPos);
					static float hullcheckmaxs[3];
					static float hullcheckmins[3];
					hullcheckmaxs = view_as<float>( { 24.0, 24.0, 82.0 } );
					hullcheckmins = view_as<float>( { -24.0, -24.0, 0.0 } );	

					float VecEnemy[3];
					WorldSpaceCenter(npc.index, VecEnemy);
					WorldSpaceCenter(npc.index, WorldSpaceVec);
					
					bool Succeed = Npc_Teleport_Safe(npc.index, vPredictedPos, hullcheckmins, hullcheckmaxs, true);
					if(Succeed)
					{
						float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
						float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
						npc.PlayTeleportSound();

						TE_Particle("pyro_blast", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
						TE_Particle("pyro_blast_lines", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
						TE_Particle("pyro_blast_warp", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
						TE_Particle("pyro_blast_flash", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
						npc.FaceTowards(VecEnemy, 15000.0);
					}
					switch(GetRandomInt(1,5))
					{
						case 1:
							Elemental_AddChaosDamage(HitEnemy, npc.index, 500, false, true);
						case 2:
							Elemental_AddNervousDamage(HitEnemy, npc.index, 500, false, true);
						case 3:
							Elemental_AddOsmosisDamage(HitEnemy, npc.index, 500);
						case 4:
							Elemental_AddNecrosisDamage(HitEnemy, npc.index, 500);
						case 5:
							Elemental_AddCyroDamage(HitEnemy, npc.index, 500, false);
					}
					ApplyStatusEffect(npc.index, HitEnemy, "Silenced", 15.0);
				}
			}
			npc.m_flDoingAnimation = 0.0;
		}
		if(npc.m_flDoingAnimation < gameTime)
		{
			npc.m_flDoingAnimation = gameTime + 0.1;
			npc.AddGesture("ACT_PUSH_PLAYER",_,_,_,4.0);
			npc.m_flRangedSpecialDelay = gameTime + 0.1;
		}
		if(npc.m_flNextRangedSpecialAttack < gameTime)
		{
			npc.m_flDoingAnimation = gameTime + 0.125;
			npc.m_flNextRangedSpecialAttack = 0.0;
		}
		return;
	}
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
					float damage = 1000.0;
					if(ShouldNpcDealBonusDamage(target))
						damage *= 1.3;

					
					if(target > 0) 
					{
						SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB);
						// Hit sound
						npc.PlayMeleeHitSound();
						if(target <= MaxClients)
							Client_Shake(target, 0, 25.0, 25.0, 0.5, false);

						switch(GetRandomInt(1,5))
						{
							case 1:
								Elemental_AddChaosDamage(target, npc.index, 500, false, true);
							case 2:
								Elemental_AddNervousDamage(target, npc.index, 500, false, true);
							case 3:
								Elemental_AddOsmosisDamage(target, npc.index, 500);
							case 4:
								Elemental_AddNecrosisDamage(target, npc.index, 500);
							case 5:
								Elemental_AddCyroDamage(target, npc.index, 500, false);
						}
						ApplyStatusEffect(npc.index, target, "Silenced", 15.0);
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
		else if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.5) && npc.m_flNextRangedAttack < gameTime)
		{
			npc.m_iState = 2; //enemy is abit further away.
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
					npc.m_flSpeed = 500.0;
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

					npc.AddGesture("ACT_MELEE_ATTACK_SWING_GESTURE", _,_,_,0.8);

					npc.PlayMeleeSound();
					
					npc.m_flAttackHappens = gameTime + 0.5;
					npc.m_flDoingAnimation = gameTime + 0.5;
					npc.m_flNextMeleeAttack = gameTime + 1.0;
					npc.m_bisWalking = true;
				}
			}
			case 2:
			{
				if(npc.m_iChanged_WalkCycle != 7) 	
				{
					npc.m_bisWalking = false;
					npc.m_iChanged_WalkCycle = 7;
					npc.SetActivity("ACT_RUN");
					npc.m_flSpeed = 0.0;
					npc.StopPathing();
				}
				npc.m_flDoingAnimation = gameTime + 1.0;
				//how long do they do their pulse attack barrage?
				npc.m_flNextRangedSpecialAttack = gameTime + 2.0;
				npc.m_flRangedSpecialDelay = gameTime + 1.0;
				npc.AddGesture("ACT_PUSH_PLAYER",_,_,_,0.4);
				npc.m_flNextRangedAttack = gameTime + 10.35;
			}
		}
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleSound();
}

public Action NightmareSwordsman_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	NightmareSwordsman npc = view_as<NightmareSwordsman>(victim);
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	
	return Plugin_Changed;
}

public void NightmareSwordsman_NPCDeath(int entity)
{
	NightmareSwordsman npc = view_as<NightmareSwordsman>(entity);
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

		
	if(EntIndexToEntRef(entity) == RaidBossActive)
		RaidBossActive = INVALID_ENT_REFERENCE;

	if(FogEntity != INVALID_ENT_REFERENCE)
	{
		int fogentity = EntRefToEntIndex(FogEntity);
		if(fogentity > MaxClients)
			RemoveEntity(fogentity);

		FogEntity = INVALID_ENT_REFERENCE;
	}
}





	
	

	
	








