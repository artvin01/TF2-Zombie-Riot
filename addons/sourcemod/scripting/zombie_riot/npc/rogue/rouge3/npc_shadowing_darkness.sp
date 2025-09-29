#pragma semicolon 1
#pragma newdecls required

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
static char g_BounceEnergOrb[][] = {
	"weapons/physcannon/energy_bounce1.wav",
	"weapons/physcannon/energy_bounce2.wav",
};
static char g_PrepareEnergyBounce[][] = {
	"npc/vort/attack_charge.wav",
};
static char g_JumpUp[][] = {
	"weapons/grenade_launcher1.wav",
};
static char g_SliceUpPortal[][] = {
	"weapons/physcannon/energy_disintegrate4.wav",
};
static char g_PointAtEnemy[][] = {
	"weapons/ar2/ar2_reload_rotate.wav",
};
static char g_TeleportAboveTarget[][] = {
	"weapons/fx/nearmiss/bulletltor09.wav",
};
static char g_LandAndDoDamage[][] = {
	"weapons/physcannon/energy_sing_explosion2.wav",
};

static char g_FireSlicer[][] = {
	"npc/vort/attack_shoot.wav",
};
static char g_teleportToAlly[][] = {
	"npc/assassin/ball_zap1.wav",
};

static const char g_ChargeCircleDo[][] =
{
	"weapons/vaccinator_charge_tier_01.wav",
};
static const char g_SummonUmbralsDo[][] =
{
	"player/souls_receive1.wav",
};
static const char g_CircleExpandDo[][] =
{
	"weapons/vaccinator_charge_tier_04.wav",
};

#define SHADOW_DEFAULT_SPEED	340.0
public void Shadowing_Darkness_Boss_OnMapStart_NPC()
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
	for (int i = 0; i < (sizeof(g_PrepareEnergyBounce)); i++) { PrecacheSound(g_PrepareEnergyBounce[i]); }
	for (int i = 0; i < (sizeof(g_JumpUp)); i++) { PrecacheSound(g_JumpUp[i]); }
	for (int i = 0; i < (sizeof(g_SliceUpPortal)); i++) { PrecacheSound(g_SliceUpPortal[i]); }
	for (int i = 0; i < (sizeof(g_PointAtEnemy)); i++) { PrecacheSound(g_PointAtEnemy[i]); }
	for (int i = 0; i < (sizeof(g_TeleportAboveTarget)); i++) { PrecacheSound(g_TeleportAboveTarget[i]); }
	for (int i = 0; i < (sizeof(g_LandAndDoDamage)); i++) { PrecacheSound(g_LandAndDoDamage[i]); }
	for (int i = 0; i < (sizeof(g_FireSlicer)); i++) { PrecacheSound(g_FireSlicer[i]); }
	for (int i = 0; i < (sizeof(g_ChargeCircleDo)); i++) { PrecacheSound(g_ChargeCircleDo[i]); }
	for (int i = 0; i < (sizeof(g_SummonUmbralsDo)); i++) { PrecacheSound(g_SummonUmbralsDo[i]); }
	for (int i = 0; i < (sizeof(g_CircleExpandDo)); i++) { PrecacheSound(g_CircleExpandDo[i]); }

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Shadowing Darkness, The Ruler");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_shadowing_darkness_boss");
	strcopy(data.Icon, sizeof(data.Icon), "shadowingdarkness");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = 0;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheSoundCustom("#zombiesurvival/rogue3/shadowing_darkness.mp3");
	PrecacheSoundCustom("#zombiesurvival/rogue3/shadowing_darkness_intro.mp3");

}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return Shadowing_Darkness_Boss(vecPos, vecAng, team, data);
}

methodmap Shadowing_Darkness_Boss < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;

		EmitSoundToAll(g_IdleSound[GetRandomInt(0, sizeof(g_IdleSound) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);

		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
	}
	
	public void PlayHurtSound()
	{
		EmitSoundToAll(g_HurtSound[GetRandomInt(0, sizeof(g_HurtSound) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);
	}
	public void PlayRangedAttackSecondarySound() {
		EmitSoundToAll(g_RangedAttackSoundsSecondary[GetRandomInt(0, sizeof(g_RangedAttackSoundsSecondary) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 50);
		EmitSoundToAll(g_RangedAttackSoundsSecondary[GetRandomInt(0, sizeof(g_RangedAttackSoundsSecondary) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 50);
		EmitSoundToAll(g_RangedAttackSoundsSecondary[GetRandomInt(0, sizeof(g_RangedAttackSoundsSecondary) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 50);
		EmitSoundToAll(g_RocketSound[GetRandomInt(0, sizeof(g_RocketSound) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,150);
		

	}
	public void PlayHealSound() 
	{
		EmitSoundToAll(g_HealSound[GetRandomInt(0, sizeof(g_HealSound) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME - 0.1, 110);

	}
	public void PlayRocketSound()
 	{
		EmitSoundToAll(g_RocketSound[GetRandomInt(0, sizeof(g_RocketSound) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,80);
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);
	}
	public void PlayKilledEnemySound(int target) 
	{
		int Health = GetEntProp(target, Prop_Data, "m_iHealth");
		
		if(Health <= 0)
		{
			switch(GetRandomInt(0,2))
			{
				case 0:
					NpcSpeechBubble(this.index, "Taa daa...", 7, {255,0,0,255}, {0.0,0.0,120.0}, "");
				case 1:
					NpcSpeechBubble(this.index, "One of my form.", 7, {255,9,9,255}, {0.0,0.0,120.0}, "");
				case 2:
					NpcSpeechBubble(this.index, "Such intellect.", 7, {255,9,9,255}, {0.0,0.0,120.0}, "");
			}
			EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);
			this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(5.0, 10.0);
		}
	}
	public void PlayMeleeSound()
 	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);
	}
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);	
	}
	public void StopPrepareBounce()
 	{
		StopSound(this.index, SNDCHAN_AUTO, g_PrepareEnergyBounce[GetRandomInt(0, sizeof(g_PrepareEnergyBounce) - 1)]);
		StopSound(this.index, SNDCHAN_AUTO, g_PrepareEnergyBounce[GetRandomInt(0, sizeof(g_PrepareEnergyBounce) - 1)]);
	}
	public void PlayPrepareBounce()
 	{
		EmitSoundToAll(g_PrepareEnergyBounce[GetRandomInt(0, sizeof(g_PrepareEnergyBounce) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,80);
	}
	public void PlayJumpUp()
 	{
		EmitSoundToAll(g_JumpUp[GetRandomInt(0, sizeof(g_JumpUp) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,80);
	}
	public void PlaySlicePortal()
 	{
		EmitSoundToAll(g_SliceUpPortal[GetRandomInt(0, sizeof(g_SliceUpPortal) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,120);
	}
	public void PlayAimAtEnemy(int enemy)
 	{
		EmitSoundToAll(g_PointAtEnemy[GetRandomInt(0, sizeof(g_PointAtEnemy) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,80);
		EmitSoundToAll(g_PointAtEnemy[GetRandomInt(0, sizeof(g_PointAtEnemy) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,80);
		if(IsValidClient(enemy))
			EmitSoundToClient(enemy, g_PointAtEnemy[GetRandomInt(0, sizeof(g_PointAtEnemy) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,80);
	}
	public void PlayTeleportAboveTarget()
 	{
		EmitSoundToAll(g_TeleportAboveTarget[GetRandomInt(0, sizeof(g_TeleportAboveTarget) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,100);
	}
	public void PlayLandSound()
 	{
		EmitSoundToAll(g_LandAndDoDamage[GetRandomInt(0, sizeof(g_LandAndDoDamage) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,90);
	}
	public void PlaySlicerDo()
 	{
		EmitSoundToAll(g_FireSlicer[GetRandomInt(0, sizeof(g_FireSlicer) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,100);
	}
	public void PlayTeleportToAlly()
 	{
		EmitSoundToAll(g_teleportToAlly[GetRandomInt(0, sizeof(g_teleportToAlly) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,80);
	}
	public void PlayChargeCircle()
 	{
		EmitSoundToAll(g_ChargeCircleDo[GetRandomInt(0, sizeof(g_ChargeCircleDo) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME - 0.1,100);
	}
	public void PlaySummonUmbrals()
 	{
		EmitSoundToAll(g_SummonUmbralsDo[GetRandomInt(0, sizeof(g_SummonUmbralsDo) - 1)], this.index, SNDCHAN_AUTO, _, _, BOSS_ZOMBIE_VOLUME,90);
		EmitSoundToAll(g_SummonUmbralsDo[GetRandomInt(0, sizeof(g_SummonUmbralsDo) - 1)], this.index, SNDCHAN_AUTO, _, _, BOSS_ZOMBIE_VOLUME,90);
	}
	public void PlayCircleExpand()
 	{
		EmitSoundToAll(g_CircleExpandDo[GetRandomInt(0, sizeof(g_CircleExpandDo) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME - 0.1,100);
	}
	
	public int FireProjectile_SD(float vecSwingStart[3], float VecAnglesDo[3], float rocket_damage, float rocket_speed , const char[] rocket_particle = "")
	{
		float vecForward[3];

		float speed = rocket_speed;
#if defined ZR
		Rogue_Paradox_ProjectileSpeed(this.index, speed);
#endif
		
		vecForward[0] = Cosine(DegToRad(VecAnglesDo[0]))*Cosine(DegToRad(VecAnglesDo[1]))*speed;
		vecForward[1] = Cosine(DegToRad(VecAnglesDo[0]))*Sine(DegToRad(VecAnglesDo[1]))*speed;
		vecForward[2] = Sine(DegToRad(VecAnglesDo[0]))*-speed;

		int entity = CreateEntityByName("zr_projectile_base");
		if(IsValidEntity(entity))
		{
			fl_Extra_Damage[entity] = fl_Extra_Damage[this.index];
			h_BonusDmgToSpecialArrow[entity] = rocket_damage;
			h_ArrowInflictorRef[entity] = this.index < 1 ? INVALID_ENT_REFERENCE : EntIndexToEntRef(this.index);
			b_should_explode[entity] = false;
			i_ExplosiveProjectileHexArray[entity] = 0;
			fl_rocket_particle_dmg[entity] = rocket_damage;
			fl_rocket_particle_radius[entity] = 0.0;
			b_rocket_particle_from_blue_npc[entity] = true;
			SetEntPropVector(entity, Prop_Send, "m_vInitialVelocity", vecForward);
			
			SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", this.index);
			SetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, 0.0, true);	// Damage
			SetTeam(entity, GetTeam(this.index));
			
			TeleportEntity(entity, vecSwingStart, VecAnglesDo, NULL_VECTOR, true);
			DispatchSpawn(entity);
			for(int i; i<4; i++) //This will make it so it doesnt override its collision box.
			{
				SetEntProp(entity, Prop_Send, "m_nModelIndexOverrides", g_rocket_particle, _, i);
			}
			SetEntityModel(entity, PARTICLE_ROCKET_MODEL);

			SetEntityRenderColor(entity, 255, 255, 255, 0);
			Hook_DHook_UpdateTransmitState(entity);
			
			int particle = 0;
	
			if(rocket_particle[0]) //If it has something, put it in. usually it has one. but if it doesn't base model it remains.
			{
				particle = ParticleEffectAt(vecSwingStart, rocket_particle, 0.0); //Inf duartion
				i_rocket_particle[entity]= EntIndexToEntRef(particle);
				TeleportEntity(particle, NULL_VECTOR, VecAnglesDo, NULL_VECTOR);
				SetParent(entity, particle);	
				SetEntityRenderMode(entity, RENDER_NONE); //Make it entirely invis.
				SetEntityRenderColor(entity, 255, 255, 255, 0);
			}
			
			TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, vecForward, true);
			SetEntityCollisionGroup(entity, 24); //our savior
			Set_Projectile_Collision(entity); //If red, set to 27

			if(h_NpcSolidHookType[entity] != 0)
				DHookRemoveHookID(h_NpcSolidHookType[entity]);
			h_NpcSolidHookType[entity] = 0;
			h_NpcSolidHookType[entity] = g_DHookRocketExplode.HookEntity(Hook_Pre, entity, Rocket_Particle_DHook_RocketExplodePre); //*yawn*
		//	SDKHook(entity, SDKHook_ShouldCollide, Never_ShouldCollide);
			SDKHook(entity, SDKHook_StartTouch, Rocket_Particle_StartTouch);
			return entity;
		}
		return -1;
	}
	property float m_flSwordParticleAttackCD
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flRestoreDefaultWalk
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flPortalSummonGate
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property float m_flUpperSlashCD
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	property float m_flCreateRingCD
	{
		public get()							{ return fl_AbilityOrAttack[this.index][4]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][4] = TempValueForProperty; }
	}

	property float m_flDespawnUmbralKoulms
	{
		public get()							{ return fl_AbilityOrAttack[this.index][5]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][5] = TempValueForProperty; }
	}

	property float m_flTeleportToStatueCD
	{
		public get()							{ return fl_AbilityOrAttack[this.index][6]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][6] = TempValueForProperty; }
	}
	property float m_flSpawnStatueUmbrals
	{
		public get()							{ return fl_AbilityOrAttack[this.index][7]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][7] = TempValueForProperty; }
	}

	property int m_iShadowingLeftSlice
	{
		public get()							{ return i_OverlordComboAttack[this.index]; }
		public set(int TempValueForProperty) 	{ i_OverlordComboAttack[this.index] = TempValueForProperty; }
	}
	property int m_iAtCurrentIntervalOfNecroArea
	{
		public get()							{ return i_MedkitAnnoyance[this.index]; }
		public set(int TempValueForProperty) 	{ i_MedkitAnnoyance[this.index] = TempValueForProperty; }
	}
	
	public Shadowing_Darkness_Boss(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Shadowing_Darkness_Boss npc = view_as<Shadowing_Darkness_Boss>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_2_MODEL, "1.15", "300", ally, false));

		SetVariantInt(16);
		AcceptEntityInput(npc.index, "SetBodyGroup");		
		i_NpcWeight[npc.index] = 4;

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		KillFeed_SetKillIcon(npc.index, "sword");


		npc.m_flNextMeleeAttack = 0.0;
		npc.m_bDissapearOnDeath = false;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;

		npc.m_flSpeed = SHADOW_DEFAULT_SPEED;

		

		bool final = StrContains(data, "final_item") != -1;
		
		if(final)
		{
			npc.SetActivity("ACT_SHADOW_IDLE_START");
			b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true;

			npc.m_bisWalking = false;
			RaidModeTime = 9999999.9;
			b_NpcUnableToDie[npc.index] = true;
			i_RaidGrantExtra[npc.index] = 1;
			f_khamlCutscene = GetGameTime() + 52.0;
			npc.m_flSpawnStatueUmbrals = GetGameTime() + 52.0;
			i_khamlCutscene = 15;				
			MusicEnum music;
			strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/rogue3/shadowing_darkness_intro.mp3");
			music.Time = 52;
			music.Volume = 1.65;
			music.Custom = true;
			strcopy(music.Name, sizeof(music.Name), "Burnt Light");
			strcopy(music.Artist, sizeof(music.Artist), "NeboScrub");
			Music_SetRaidMusic(music);
			CPrintToChatAll("{darkgray}Shadowing Darkness{default}: Oh its you lot, finally you actually prevailed.");
		}
		else
		{
			npc.SetActivity("ACT_SHADOW_RUN");
			RaidModeTime = GetGameTime() + (350.0);
			MusicEnum music;
			strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/rogue3/shadowing_darkness.mp3");
			music.Time = 210;
			music.Volume = 1.35;
			music.Custom = true;
			strcopy(music.Name, sizeof(music.Name), "Burnt Light");
			strcopy(music.Artist, sizeof(music.Artist), "NeboScrub");
			Music_SetRaidMusic(music);
			npc.m_flSpawnStatueUmbrals = 1.0;
		}


		EmitSoundToAll("ambient/machines/teleport3.wav", _, _, _, _, 1.0);	
		EmitSoundToAll("ambient/machines/teleport3.wav", _, _, _, _, 1.0);	
		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				SetGlobalTransTarget(client_check);
				ShowGameText(client_check, "item_armor", 1, "%t", "Shadowing Darkness The Ruler");
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
		
		float amount_of_people = ZRStocks_PlayerScalingDynamic();
		if(amount_of_people > 12.0)
		{
			amount_of_people = 12.0;
		}
		amount_of_people *= 0.12;
		
		if(amount_of_people < 1.0)
			amount_of_people = 1.0;

		RaidModeScaling *= amount_of_people; //More then 9 and he raidboss gets some troubles, bufffffffff
		
		npc.m_flMeleeArmor = 1.25;	

		RaidBossActive = EntIndexToEntRef(npc.index);
		RaidAllowsBuildings = false;
		Citizen_MiniBossSpawn();
		npc.m_flSwordParticleAttackCD = GetGameTime() + 10.0;
		npc.m_flPortalSummonGate = GetGameTime() + 25.0;
		npc.m_flUpperSlashCD = GetGameTime() + 15.0;
		npc.m_flCreateRingCD = GetGameTime() + 30.0;
		npc.m_flTeleportToStatueCD = GetGameTime() + 25.0;

		func_NPCDeath[npc.index] = Shadowing_Darkness_Boss_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Shadowing_Darkness_Boss_OnTakeDamage;
		func_NPCThink[npc.index] = Shadowing_Darkness_Boss_ClotThink;

		b_thisNpcIsARaid[npc.index] = true;
		b_thisNpcIsABoss[npc.index] = true;

		func_NPCFuncWin[npc.index] = view_as<Function>(Shadowing_DarknessWinLine);
		
		npc.StartPathing();
		AlreadySaidWin = false;
		
		return npc;
	}
	
}

public void Shadowing_DarknessWinLine(int entity)
{
	i_RaidGrantExtra[entity] = RAIDITEM_INDEX_WIN_COND;
	func_NPCThink[entity] = INVALID_FUNCTION;
	if(AlreadySaidWin)
		return;

	AlreadySaidWin = true;
	CPrintToChatAll("{darkgray}Shadowing Darkness{default}: Oh dont worry, I wont kill you\nI'll make sure that you understand what beauty this place is.");	
}

public void Shadowing_Darkness_Boss_ClotThink(int iNPC)
{
	Shadowing_Darkness_Boss npc = view_as<Shadowing_Darkness_Boss>(iNPC);

	float gameTime = GetGameTime(npc.index);

	if(IsValidEntity(npc.m_iTargetAlly))
	{
		//unspeakable is alive, nerf me
		ApplyStatusEffect(iNPC, iNPC, "Terrified", 1.0);
		ApplyStatusEffect(iNPC, iNPC, "Unstoppable Force", 1.0);
		if(npc.m_flRestoreDefaultWalk != 1.0)
			npc.m_flRestoreDefaultWalk = gameTime + 0.1;
	}
	//some npcs deservere full update time!
	if(npc.m_flNextDelayTime > gameTime)
	{
		return;
	}

	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();	
	if(Shadowing_Darkness_TalkStart(npc))
	{
		return;
	}

	if(npc.m_flSpawnStatueUmbrals)
	{
		if(npc.m_flSpawnStatueUmbrals < GetGameTime(npc.index))
		{
			ShadowingDarkness_SpawnStatues(npc, "giant_shadow_statue_4");
			ShadowingDarkness_SpawnStatues(npc, "giant_shadow_statue_3");
			npc.m_flSpawnStatueUmbrals = 0.0;
		}
	}

	if(npc.m_blPlayHurtAnimation && npc.m_flDoingAnimation < gameTime) //Dont play dodge anim if we are in an animation.
	{
		npc.AddGesture("ACT_HURT", false);
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}

	if(npc.m_flNextThinkTime != FAR_FUTURE && RaidModeTime < GetGameTime())
	{
		if(IsValidEntity(RaidBossActive))
		{
			ForcePlayerLoss();
			RaidBossActive = INVALID_ENT_REFERENCE;
		}
		func_NPCThink[npc.index] = INVALID_FUNCTION;
		npc.StopPathing();
		npc.m_flNextThinkTime = FAR_FUTURE;
		i_RaidGrantExtra[npc.index] = 0;
		CPrintToChatAll("{darkgray}Shadowing Darkness{default}: So you finally understand the calmness of this place, stop fighting, resisting is futile~");	
	}

	if(npc.m_flNextThinkTime > gameTime)
	{
		return;
	}
	npc.m_flNextThinkTime = gameTime + 0.1;

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	if(Shadowing_Darkness_SwordParticleAttack(npc, gameTime))
	{
		return;
	}

	if(Shadowing_Darkness_UmbralGateSummoner(npc, gameTime))
	{
		return;
	}

	if(Shadowing_Darkness_UpperDash(npc, gameTime))
	{
		return;
	}

	if(Shadowing_Darkness_CreateRing(npc, gameTime))
	{
		return;
	}
	if(Shadowing_Darkness_StatueTeleport(npc, gameTime))
	{
		return;
	}

	Shadowing_Darkness_DefaultMovement(npc, gameTime);
	if(npc.m_flDespawnUmbralKoulms < gameTime)
	{
		//delete all koulms
		int inpcloop, a;
		while((inpcloop = FindEntityByNPC(a)) != -1)
		{
			if(IsValidEntity(inpcloop) && i_NpcInternalId[inpcloop] == Umbral_Koulm_ID())
			{
				if(inpcloop != 0)
				{
					b_DissapearOnDeath[inpcloop] = true;
					b_DoGibThisNpc[inpcloop] = true;
					SmiteNpcToDeath(inpcloop);
					SmiteNpcToDeath(inpcloop);
					SmiteNpcToDeath(inpcloop);
					SmiteNpcToDeath(inpcloop);
				}
			}
		}
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
		Shadowing_Darkness_SelfDefense(npc,GetGameTime(npc.index), flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleSound();
}


public Action Shadowing_Darkness_Boss_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;

	Shadowing_Darkness_Boss npc = view_as<Shadowing_Darkness_Boss>(victim);

	float gameTime = GetGameTime(npc.index);

	if (npc.m_flHeadshotCooldown < gameTime)
	{
		npc.m_flHeadshotCooldown = gameTime + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}

	int Health = GetEntProp(victim, Prop_Data, "m_iHealth");
	if(RoundToCeil(damage) > Health && i_RaidGrantExtra[npc.index] == 1)
	{	
		
		float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
		float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
		SetTeam(victim, 2);
		//force red team
		int spawn_index = NPC_CreateByName("npc_void_unspeakable", -1, pos, ang, 3, "shadowcutscene");
		if(spawn_index > MaxClients)
		{
			NpcStats_CopyStats(npc.index, spawn_index);
			NpcAddedToZombiesLeftCurrently(spawn_index, true);
			SetEntProp(spawn_index, Prop_Data, "m_iHealth", 1000000000);
			SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", 1000000000);
			f_AttackSpeedNpcIncrease[spawn_index]	*= 2.0;
			fl_Extra_Damage[spawn_index]	*= 0.1;

		}
		if(npc.m_iChanged_WalkCycle != 99) 	
		{
			npc.m_bisWalking = false;
			npc.m_iChanged_WalkCycle = 99;
			npc.SetActivity("ACT_SHADOW_IDLE_VOICE");
			npc.m_flSpeed = 0.0;
			npc.StopPathing();
		}
		i_RaidGrantExtra[npc.index] = 2;
		CPrintToChatAll("{purple}NO!!!!!!");
		CPrintToChatAll("{darkgray}Shadowing Darkness{default}: Get this thing off me-.");
		CPrintToChatAll("{black}Izan :{default} What the-");
		if(Rogue_HasNamedArtifact("Vhxis' Assistance"))
			CPrintToChatAll("{purple}Vhxis{default}: DON'T YOU DARE TO THINK ABOUT DOING IT!");
		if(Rogue_HasNamedArtifact("Omega's Assistance"))
			CPrintToChatAll("{gold}Omega{default}: How in the hell do we stop that damn thing!?");
		FreezeNpcInTime(victim, 30.0, true);
		damage = 0.0;
		SetEntProp(npc.index, Prop_Data, "m_iHealth", 1);

		
		//delete all koulms
		int inpcloop, a;
		while((inpcloop = FindEntityByNPC(a)) != -1)
		{
			if(IsValidEntity(inpcloop) && i_NpcInternalId[inpcloop] == Umbral_Koulm_ID())
			{
				if(inpcloop != 0)
				{
					b_DissapearOnDeath[inpcloop] = true;
					b_DoGibThisNpc[inpcloop] = true;
					SmiteNpcToDeath(inpcloop);
					SmiteNpcToDeath(inpcloop);
					SmiteNpcToDeath(inpcloop);
					SmiteNpcToDeath(inpcloop);
				}
			}
		}
		//delete all koulms
		int inpcloop1, a1;
		while((inpcloop1 = FindEntityByNPC(a1)) != -1)
		{
			if(IsValidEntity(inpcloop1) && i_NpcInternalId[inpcloop1] == Umbral_Automaton_ID())
			{
				if(inpcloop1 != 0)
				{
					b_DissapearOnDeath[inpcloop1] = true;
					b_DoGibThisNpc[inpcloop1] = true;
					SmiteNpcToDeath(inpcloop1);
					SmiteNpcToDeath(inpcloop1);
					SmiteNpcToDeath(inpcloop1);
					SmiteNpcToDeath(inpcloop1);
				}
			}
		}
		return Plugin_Changed;
	}
	int maxhealth = ReturnEntityMaxHealth(npc.index);
	float ratio = float(GetEntProp(npc.index, Prop_Data, "m_iHealth")) / float(maxhealth);
	if(0.9-(npc.g_TimesSummoned*0.2) > ratio)
	{
		npc.g_TimesSummoned++;
		ApplyStatusEffect(npc.index, npc.index, "Very Defensive Backup", 5.0);
	//	ApplyStatusEffect(npc.index, npc.index, "Umbral Grace Debuff", 5.0);
		ApplyStatusEffect(npc.index, npc.index, "Umbral Grace", 5.0);
		switch(GetRandomInt(1,3))
		{
			case 1:
				CPrintToChatAll("{darkgray}Shadowing Darkness{default}: Umbrals, Assist me!");
			case 2:
				CPrintToChatAll("{darkgray}Shadowing Darkness{default}: Need some resis against them...");
			case 3:
				CPrintToChatAll("{darkgray}Shadowing Darkness{default}: Umbral armor should prevent this.");
		}
	}
	if(!npc.Anger)
	{
		if(Health <= (ReturnEntityMaxHealth(npc.index) / 2))
		{	
			npc.Anger = true;
			float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
			float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
			int spawn_index = NPC_CreateByName("npc_void_unspeakable", -1, pos, ang, GetTeam(npc.index), "shadowbattle");
			if(spawn_index > MaxClients)
			{
				NpcStats_CopyStats(npc.index, spawn_index);
				NpcAddedToZombiesLeftCurrently(spawn_index, true);
				SetEntProp(spawn_index, Prop_Data, "m_iHealth", (ReturnEntityMaxHealth(npc.index) / 3));
				SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", (ReturnEntityMaxHealth(npc.index) / 3));
				ApplyStatusEffect(spawn_index, spawn_index, "Extreme Anxiety", 10.0);
				npc.m_iTargetAlly = spawn_index;
			}
			if(npc.m_flSpeed != 0)
				npc.m_flSpeed = SHADOW_DEFAULT_SPEED * 0.5;
			CPrintToChatAll("{purple}YOU WILL NOT SEE THE END OF THIS DAY...");
			CPrintToChatAll("{darkgray}Shadowing Darkness{default}: So i was right, i wasn't alone once i sat on that throne, parasite...");
			if(Rogue_HasNamedArtifact("Vhxis' Assistance"))
				CPrintToChatAll("{purple}Vhxis{default}: You god damn vermin, I thought I had seen the last of you!");
			if(Rogue_HasNamedArtifact("Omega's Assistance"))
				CPrintToChatAll("{gold}Omega{default}: What in the world is THAT?");
			
			damage = 0.0;
			SetEntProp(npc.index, Prop_Data, "m_iHealth", ReturnEntityMaxHealth(npc.index) / 2);	
			return Plugin_Changed;
		}
	}
	
	return Plugin_Changed;
}

public void Shadowing_Darkness_Boss_NPCDeath(int entity)
{
	Shadowing_Darkness_Boss npc = view_as<Shadowing_Darkness_Boss>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();
	}
		
	//delete all koulms
	int inpcloop, a;
	while((inpcloop = FindEntityByNPC(a)) != -1)
	{
		if(IsValidEntity(inpcloop) && i_NpcInternalId[inpcloop] == Umbral_Koulm_ID())
		{
			if(inpcloop != 0)
			{
				b_DissapearOnDeath[inpcloop] = true;
				b_DoGibThisNpc[inpcloop] = true;
				SmiteNpcToDeath(inpcloop);
				SmiteNpcToDeath(inpcloop);
				SmiteNpcToDeath(inpcloop);
				SmiteNpcToDeath(inpcloop);
			}
		}
	}
	//delete all koulms
	int inpcloop1, a1;
	while((inpcloop1 = FindEntityByNPC(a1)) != -1)
	{
		if(IsValidEntity(inpcloop1) && i_NpcInternalId[inpcloop1] == Umbral_Automaton_ID())
		{
			if(inpcloop1 != 0)
			{
				b_DissapearOnDeath[inpcloop1] = true;
				b_DoGibThisNpc[inpcloop1] = true;
				SmiteNpcToDeath(inpcloop1);
				SmiteNpcToDeath(inpcloop1);
				SmiteNpcToDeath(inpcloop1);
				SmiteNpcToDeath(inpcloop1);
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

public void Shadowing_Darkness_Boss_NPCDeath_After(int entity)
{
	Shadowing_Darkness_Boss npc = view_as<Shadowing_Darkness_Boss>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();
	}
	npc.StopPrepareBounce();
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
}



void Shadowing_Darkness_SelfDefense(Shadowing_Darkness_Boss npc, float gameTime, float distance)
{
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			Handle swingTrace;
			float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);
			if(npc.DoSwingTrace(swingTrace, npc.m_iTarget))
			{	
				int target = TR_GetEntityIndex(swingTrace);	
				
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				
				//Shw will not an AOE melee swing, it would be too much.
				if(IsValidEnemy(npc.index, target))
				{
					float damageDealt = 65.0;
					damageDealt *= RaidModeScaling;
					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);

					//they will give Necrosis damage.
					Elemental_AddNecrosisDamage(target, npc.index, RoundToCeil(RaidModeScaling * 15.0));

					// Hit sound
					npc.PlayMeleeHitSound();
				} 
			}
			delete swingTrace;
		}
	}

	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
		{
			int Enemy_I_See;
								
			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.PlayMeleeSound();
				switch(GetRandomInt(1,2))
				{
					case 1:
					{
						npc.AddGesture("ACT_SHADOW_ATTACK_1",_,_,_,1.0);
					}
					case 2:
					{
						npc.AddGesture("ACT_SHADOW_ATTACK_2",_,_,_,1.0);
					}
				}
				npc.m_flAttackHappens = gameTime + 0.2;
				npc.m_flDoingAnimation = gameTime + 0.2;
				npc.m_flNextMeleeAttack = gameTime + 0.6;
			}
		}
	}
}
#define SD_PROJ_SPEED 1400.0
bool Shadowing_Darkness_SwordParticleAttack(Shadowing_Darkness_Boss npc, float gameTime)
{

	if(npc.m_flSwordParticleAttackCD < gameTime && npc.m_iState == 0)
	{
		npc.m_flSwordParticleAttackCD = gameTime + 25.0;
		npc.m_iState = 1;
		npc.m_flDoingAnimation = gameTime + 1.5;
		if(npc.m_iChanged_WalkCycle != 1) 	
		{
			npc.m_bisWalking = false;
			npc.m_iChanged_WalkCycle = 1;
			switch(GetRandomInt(1,2))
			{
				case 1:
				{
					npc.AddGesture("ACT_SHADOW_SWIPE_LEFT",_,_,_,1.0);
				}
				case 2:
				{
					npc.AddGesture("ACT_SHADOW_SWIPE_RIGHT",_,_,_,1.0);
				}
			}
			npc.m_flSpeed = 0.0;
			npc.StopPathing();
		}
		npc.PlayPrepareBounce();
	}

	if(npc.m_iState == 1)
	{
		float TimeLeft = npc.m_flDoingAnimation - gameTime;
		if(!IsValidEnemy(npc.index, npc.m_iTarget))
		{
			npc.m_iTarget = GetClosestTarget(npc.index);
			//get the next valid enemy
			if(npc.m_iTarget == -1)
			{
				//no valid target, end ability now
				TimeLeft = 0.0;
			}
		}
		if(TimeLeft <= 0.0)
		{
			//Reset back to normal, we are done.
			npc.m_iState = 0;
			npc.m_flRestoreDefaultWalk = 1.0;
		}
		else if(TimeLeft <= 0.5)
		{
			//do whatever after some time
			if(npc.m_iChanged_WalkCycle != 2) 	
			{
				npc.m_bisWalking = false;
				npc.m_iChanged_WalkCycle = 2;
			//	npc.SetActivity("ACT_SHADOW_RUN");
				npc.m_flSpeed = 0.0;
				npc.StopPathing();
				npc.StopPrepareBounce();

				//ability stuff
				float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
				float vecSelf[3]; WorldSpaceCenter(npc.index, vecSelf );
				float vecAngles[3], EndPos[3];
				float vecAnglesLoop[3] ,VecSpeed[3];
				MakeVectorFromPoints(vecSelf, vecTarget, vecAngles);
				GetVectorAngles(vecAngles, vecAngles);
				float vecTargetProj[3]; //empty
				npc.PlayRangedAttackSecondarySound();
				for(int loop; loop < 8 ;loop ++)
				{
					vecAnglesLoop = vecAngles;
					/*
						its 3.75 cus	we go down in the axis by -15, and then we go up by that amount so it becomes the opposite.
						i.e. at the middle. normal angles, at the end, opposite offset.
					 */
					vecAnglesLoop[0] += (((-15.0 + ( loop * 3.75))) * 0.25);
					vecAnglesLoop[1] += (-15.0 + ( loop * 3.75));
					int projectile = npc.FireProjectile_SD(vecSelf, vecAnglesLoop,  280.0 , 0.0, "raygun_projectile_red");
					SD_ProjectileToEnemy(projectile, vecTargetProj, vecAnglesLoop, VecSpeed, EndPos);
					DataPack pack = new DataPack();
					pack.WriteCell(EntIndexToEntRef(projectile));
					pack.WriteFloat(VecSpeed[0]);
					pack.WriteFloat(VecSpeed[1]);
					pack.WriteFloat(VecSpeed[2]);
					RequestFrames(SD_ProjectileGiveSpeed, (loop * 2), pack);
					WorldSpaceCenter(projectile, vecSelf);

					TE_SetupBeamPoints(vecSelf, EndPos, Shared_BEAM_Laser, 0, 0, 0, 1.5, 3.0, 3.0, 0, 0.0, {255,65,65,125}, 3);
					TE_SendToAll(0.0);
					//override normal touch stuff
					SDKUnhook(projectile, SDKHook_StartTouch, Rocket_Particle_StartTouch);
					SDKHook(projectile, SDKHook_StartTouch, Shadowing_Darkness_ReflectProjectiles);		

				}
			}
		}
		return true;
	}
	return false;
}

#define MAX_BOUNCES_SHADOWING_DARKNESS 3
public void Shadowing_Darkness_ReflectProjectiles(int entity, int target)
{
	CClotBody npc = view_as<CClotBody>(entity);
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if(!IsValidEntity(owner))
	{
		owner = 0;
	}
	if(npc.m_iState >= MAX_BOUNCES_SHADOWING_DARKNESS || IsValidEnemy(entity, target, true, true))
	{
		//valid target, do damage!
		Rocket_Particle_StartTouch(entity, target);
		SDKUnhook(entity, SDKHook_StartTouch, Shadowing_Darkness_ReflectProjectiles);		
		return;
	}
	npc.m_iState++;
	float pos[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
	TE_Particle("mvm_soldier_shockwave", pos, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
	EmitSoundToAll(g_BounceEnergOrb[GetRandomInt(0, sizeof(g_BounceEnergOrb) - 1)], _, SNDCHAN_AUTO, 80, _,1.0, 150,_,pos);
	int EnemySearch = GetClosestTarget(entity, true, _, true, _, _, _, true, .UseVectorDistance = true);
	if(EnemySearch == -1)
	{
		//no valid target found...
		//bounce back exactly the oposite of your speed
		float ProjectileVel[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsVelocity", ProjectileVel);
		NegateVector(ProjectileVel);
		TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, ProjectileVel);
		return;
	}

	float VecAngles[3], VecSpeed[3], EndPos[3], vecEnemy[3];
	WorldSpaceCenter(EnemySearch, vecEnemy);
	SD_ProjectileToEnemy(entity, vecEnemy, VecAngles, VecSpeed, EndPos);
	float vecSelf[3];
	WorldSpaceCenter(entity, vecSelf);
	TE_SetupBeamPoints(vecSelf, EndPos, Shared_BEAM_Laser, 0, 0, 0, 1.5, 3.0, 3.0, 0, 0.0, {255,65,65,125}, 3);
	TE_SendToAll(0.0);
	TeleportEntity(entity, NULL_VECTOR, VecAngles, VecSpeed);
	//valid target found, bounce to said target
}


void SD_ProjectileToEnemy(int projectile, float vecEnemy[3], float VecAngles[3], float VecSpeed[3], float EndPos[3])
{
	float vecSelf[3];
	WorldSpaceCenter(projectile, vecSelf);
	
	if(vecEnemy[0] != 0.0)
	{
		MakeVectorFromPoints(vecSelf, vecEnemy, VecAngles);
		GetVectorAngles(VecAngles, VecAngles);
	}
	VecSpeed[0] = Cosine(DegToRad(VecAngles[0]))*Cosine(DegToRad(VecAngles[1]))*SD_PROJ_SPEED;
	VecSpeed[1] = Cosine(DegToRad(VecAngles[0]))*Sine(DegToRad(VecAngles[1]))*SD_PROJ_SPEED;
	VecSpeed[2] = Sine(DegToRad(VecAngles[0]))*-SD_PROJ_SPEED;
	//get endpoint

	//incase trace fails
	EndPos = vecEnemy;
	Handle trace = TR_TraceRayFilterEx(vecSelf, VecAngles, MASK_SHOT, RayType_Infinite, TraceRayHitWorldOnly);

	if(TR_DidHit(trace))
   	 	TR_GetEndPosition(EndPos, trace);

	delete trace;
}

stock void SD_ProjectileGiveSpeed(DataPack pack)
{
	pack.Reset();
	int Projectile = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidEntity(Projectile))
	{
		delete pack;
		return;
	}
	float VectorSpeed[3];
	VectorSpeed[0] = pack.ReadFloat();
	VectorSpeed[1] = pack.ReadFloat();
	VectorSpeed[2] = pack.ReadFloat();

	TeleportEntity(Projectile, NULL_VECTOR, NULL_VECTOR, VectorSpeed);
	delete pack;

}


void Shadowing_Darkness_DefaultMovement(Shadowing_Darkness_Boss npc, float gameTime)
{
	if(!npc.m_flRestoreDefaultWalk)
		return;
		
	if(npc.m_flRestoreDefaultWalk > gameTime)
		return;

	npc.StopPrepareBounce();
	npc.m_flRestoreDefaultWalk = 0.0;
	npc.m_bisWalking = true;
	npc.m_iChanged_WalkCycle = 0;
	npc.SetActivity("ACT_SHADOW_RUN");
	npc.m_flSpeed = SHADOW_DEFAULT_SPEED;
	if(IsValidEntity(npc.m_iTargetAlly))
		npc.m_flSpeed = SHADOW_DEFAULT_SPEED * 0.5;
	npc.StartPathing();
}


bool Shadowing_Darkness_UmbralGateSummoner(Shadowing_Darkness_Boss npc, float gameTime)
{
	if(npc.m_flPortalSummonGate < gameTime && npc.m_iState == 0)
	{
		npc.m_flPortalSummonGate = gameTime + 90.0;
		npc.m_iState = 2;	
		npc.m_flDoingAnimation = gameTime + 1.5;
		if(npc.m_iChanged_WalkCycle != 1) 	
		{
			npc.m_bisWalking = false;
			npc.m_iChanged_WalkCycle = 1;
			npc.SetActivity("ACT_SHADOW_EYE");
			npc.SetPlaybackRate(1.5);
			npc.m_flSpeed = 0.0;
			npc.StopPathing();
		}
	}

	if(npc.m_iState == 2)
	{
		float TimeLeft = npc.m_flDoingAnimation - gameTime;
		if(TimeLeft <= 0.0)
		{
			//Reset back to normal, we are done.
			npc.m_iState = 0;
			npc.m_flRestoreDefaultWalk = 1.0;
		}
		else if(TimeLeft <= 0.5)
		{
			//do a big slice and summon portal entity
			if(npc.m_iChanged_WalkCycle != 2) 	
			{
				npc.m_bisWalking = false;
				npc.m_iChanged_WalkCycle = 2;
			//	npc.SetActivity("ACT_SHADOW_RUN");
				npc.m_flSpeed = 0.0;
				npc.StopPathing();
				
				float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
				float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
				
				int spawn_index = NPC_CreateByName("npc_torn_umbral_gate", -1, pos, ang, GetTeam(npc.index));
				if(spawn_index > MaxClients)
				{
					NpcStats_CopyStats(npc.index, spawn_index);
					NpcAddedToZombiesLeftCurrently(spawn_index, true);
					SetEntProp(spawn_index, Prop_Data, "m_iHealth", (ReturnEntityMaxHealth(npc.index) / 8));
					SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", (ReturnEntityMaxHealth(npc.index) / 8));

				}
				npc.PlaySlicePortal();
			}
		}
		else if(TimeLeft <= 1.5)
		{
			//do whatever after some time
			if(npc.m_iChanged_WalkCycle != 3) 	
			{
				npc.m_bisWalking = false;
				npc.m_iChanged_WalkCycle = 3;
			//	npc.SetActivity("ACT_SHADOW_RUN");
				npc.m_flSpeed = 0.0;
				npc.StopPathing();

				//ability stuff
				float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
				float vecSelf[3]; WorldSpaceCenter(npc.index, vecSelf );
				//as of now, just badly jump up and do a portal there
				
				static float flPos[3]; 
				GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flPos);
				ParticleEffectAt(flPos, "taunt_flip_land_red", 0.25);
				flPos[2] += 350.0;
				flPos[0] += GetRandomInt(0,1) ? GetRandomFloat(-400.0, -300.0) : GetRandomFloat(300.0, 400.0);
				flPos[1] += GetRandomInt(0,1) ? GetRandomFloat(-400.0, -300.0) : GetRandomFloat(300.0, 400.0);
				npc.SetVelocity({0.0,0.0,0.0});
				PluginBot_Jump(npc.index, flPos);
				npc.PlayJumpUp();
			}
		}
		return true;
	}
	return false;
}


bool Shadowing_Darkness_UpperDash(Shadowing_Darkness_Boss npc, float gameTime)
{
	if(npc.m_flUpperSlashCD < gameTime && npc.m_iState == 0)
	{
		npc.m_flUpperSlashCD = gameTime + 50.0;
		npc.m_iState = 3;	
		npc.m_flDoingAnimation = gameTime + 2.3;
		if(npc.m_iChanged_WalkCycle != 1) 	
		{
			npc.m_bisWalking = false;
			npc.m_iChanged_WalkCycle = 1;
			npc.SetActivity("ACT_SHADOW_POINT");
			npc.SetPlaybackRate(0.95);
			npc.m_flSpeed = 0.0;
			npc.StopPathing();
		}
		npc.m_iAtCurrentIntervalOfNecroArea++;
		npc.m_iShadowingLeftSlice = 3;
		npc.m_iTargetWalkTo = npc.m_iTarget;
	}

	if(npc.m_iState == 3)
	{
		static float HullMaxs[3];
		static float HullMins[3];
		HullMaxs = view_as<float>( { 24.0, 24.0, 82.0 } );
		HullMins = view_as<float>( { -24.0, -24.0, 0.0 } );
		if(f3_NpcSavePos[npc.index][2] != -69.69)
		{
			static float HullMaxs_Dmg[3];
			static float HullMins_Dmg[3];
			HullMaxs_Dmg = view_as<float>( { 80.0, 80.0, 150.0 } );
			HullMins_Dmg = view_as<float>( { -80.0, -80.0, 0.0 } );
			TE_DrawBox(-1, f3_NpcSavePos[npc.index], HullMins_Dmg, HullMaxs_Dmg, 0.15, view_as<int>({255, 0, 0, 255}));
		}

		float TimeLeft = npc.m_flDoingAnimation - gameTime;
		if(TimeLeft <= 0.0)
		{
			//done with ability
			RemoveSpecificBuff(npc.index, "Intangible");
			f_CheckIfStuckPlayerDelay[npc.index] = 0.0;
			b_ThisEntityIgnoredBeingCarried[npc.index] = false; 
			//Reset back to normal, we are done.
			npc.m_iTargetWalkTo = 0;
			npc.m_iState = 0;
			npc.m_flRestoreDefaultWalk = 1.0;
			b_NoGravity[npc.index] = false;
			f3_NpcSavePos[npc.index][2] = -69.69;
		}
		else if(TimeLeft <= 0.6)
		{
			if(npc.m_iChanged_WalkCycle != 7) 	
			{
				if(npc.m_iShadowingLeftSlice > 0)
				{
					npc.m_bisWalking = false;
					npc.m_bisWalking = false;
					npc.m_iChanged_WalkCycle = 7;
					npc.SetActivity("ACT_SHADOW_POINT");
					npc.SetCycle(0.45);
					npc.SetPlaybackRate(1.2);
					npc.m_flSpeed = 0.0;
					npc.StopPathing();
				
					npc.m_iShadowingLeftSlice--;
					npc.m_flDoingAnimation = gameTime + 1.8;
				}
			}
		}
		else if(TimeLeft <= 0.75)
		{
			if (!npc.IsOnGround())
			{
				npc.m_flDoingAnimation = gameTime + 1.15;
			}
			else if(npc.m_iChanged_WalkCycle != 6) 	
			{
				if(IsValidEnemy(npc.index, npc.m_iTargetWalkTo, true, true))
				{
					float VecMe[3]; WorldSpaceCenter(npc.index, VecMe);
					float VecEnemy[3];
					WorldSpaceCenter(npc.m_iTargetWalkTo, VecEnemy);
					PredictSubjectPositionForProjectiles(npc, npc.m_iTargetWalkTo, 500.0, _,VecEnemy);
					float DamageCalc = 150.0;
					DamageCalc *= RaidModeScaling;
					//basically oneshots
					NemalAirSlice(npc.index,npc.m_iTargetWalkTo, DamageCalc, 255, 125, 125, 300.0, 8, 1200.0, "raygun_projectile_red", false, true, true);
					NemalAirSlice(npc.index,npc.m_iTargetWalkTo, DamageCalc, 255, 125, 125, 300.0, 8, 1200.0, "raygun_projectile_red", false, true, false);
				}
				npc.m_bisWalking = false;
				npc.m_iChanged_WalkCycle = 6;
			//	npc.SetActivity("ACT_SHADOW_PROJECTILE");
			//	npc.SetCycle(0.3);
			//	npc.SetPlaybackRate(1.3);
				npc.m_flSpeed = 0.0;
				npc.StopPathing();

				npc.PlaySlicerDo();
				//do slice
			}
		}
		else if(TimeLeft <= 1.0)
		{	
			if (!npc.IsOnGround())
			{
				npc.m_flDoingAnimation = gameTime + 1.15;
			}
			else
			{
				if(npc.m_iChanged_WalkCycle != 9) 	
				{
					npc.m_bisWalking = false;
					npc.m_iChanged_WalkCycle = 9;
					npc.SetActivity("ACT_SHADOW_PROJECTILE");
					npc.SetCycle(0.3);
					npc.SetPlaybackRate(1.5);
					npc.m_flSpeed = 0.0;
					npc.StopPathing();
					
					static float flPos[3]; 
					GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flPos);
					flPos[2] += 5.0;
					int PoolAidsParticle = ParticleEffectAt(flPos, "utaunt_wiggletube_teamcolor_red", 0.0);
					DataPack pack;
					CreateDataTimer(0.25, ShadowingDarkness_NecroPoolTimer, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
					pack.WriteCell(EntIndexToEntRef(npc.index));
					pack.WriteCell(EntIndexToEntRef(PoolAidsParticle));
					pack.WriteCell(npc.m_iAtCurrentIntervalOfNecroArea);	
					npc.PlayLandSound();
					//do slice
				}
			}
		}
		else if(TimeLeft <= 1.25)
		{
			if(IsValidEnemy(npc.index, npc.m_iTargetWalkTo, true, true))
			{
				float VecMe[3]; WorldSpaceCenter(npc.index, VecMe);
				float VecEnemy[3];
				WorldSpaceCenter(npc.m_iTargetWalkTo, VecEnemy);
				PredictSubjectPositionForProjectiles(npc, npc.m_iTargetWalkTo, 500.0, _,VecEnemy);
				npc.FaceTowards(VecEnemy, 15000.0);
			}
			if(npc.m_iChanged_WalkCycle != 5) 	
			{
				npc.m_bisWalking = false;
				npc.m_iChanged_WalkCycle = 5;
				npc.SetActivity("ACT_SHADOW_IDLE");
				npc.m_flSpeed = 0.0;
				npc.StopPathing();
				b_NoGravity[npc.index] = false;
				
				f3_NpcSavePos[npc.index][2] = -69.69;
				npc.SetVelocity({0.0,0.0,-2000.0});
			}
		}
		else if(TimeLeft <= 1.5)
		{
			if(npc.m_iChanged_WalkCycle != 4) 	
			{
				npc.m_bisWalking = false;
				npc.m_iChanged_WalkCycle = 4;
				npc.SetActivity("ACT_SHADOW_UPPERCUT");
				npc.m_flSpeed = 0.0;
				npc.StopPathing();

				static float flPos[3]; 
				GetEntPropVector(npc.m_iTargetWalkTo, Prop_Data, "m_vecAbsOrigin", flPos);
				flPos[2] += 150.0;

				f3_NpcSavePos[npc.index] = flPos;
				f3_NpcSavePos[npc.index][2] -= 150.0;
				ApplyStatusEffect(npc.index, npc.index, "Intangible", 999999.0);
				b_ThisEntityIgnoredBeingCarried[npc.index] = true; //cant be targeted AND wont do npc collsiions
				f_CheckIfStuckPlayerDelay[npc.index] = FAR_FUTURE; //She CANT stuck you, so dont make players not unstuck in cant bve stuck ? what ?

				
				int r = 255;
				int g = 65;
				int b = 65;
				float diameter = 25.0;
				int colorLayer4[4];
				SetColorRGBA(colorLayer4, r, g, b, 233);
				float VecMe[3]; WorldSpaceCenter(npc.index, VecMe);

				Npc_Teleport_Safe(npc.index, flPos, HullMins, HullMaxs, false, true, true);
				npc.PlayTeleportAboveTarget();

				b_NoGravity[npc.index] = true;
				float VecMeNew[3]; WorldSpaceCenter(npc.index, VecMeNew);
				
				TE_SetupBeamPoints(VecMe, VecMeNew, g_Ruina_BEAM_Laser, 0, 0, 0, 0.75, ClampBeamWidth(diameter * 0.1 * 1.28), ClampBeamWidth(diameter * 0.1 * 1.28), 0, 1.0, colorLayer4, 3);
				TE_SendToAll(0.0);
				TE_SetupBeamPoints(VecMe, VecMeNew, g_Ruina_BEAM_Laser, 0, 0, 0, 0.5, ClampBeamWidth(diameter * 0.2 * 1.28), ClampBeamWidth(diameter * 0.2 * 1.28), 0, 1.0, colorLayer4, 3);
				TE_SendToAll(0.0);
				TE_SetupBeamPoints(VecMe, VecMeNew, g_Ruina_BEAM_Laser, 0, 0, 0, 0.3, ClampBeamWidth(diameter * 0.3 * 1.28), ClampBeamWidth(diameter * 0.3 * 1.28), 0, 1.0, colorLayer4, 3);
				TE_SendToAll(0.0);
				TE_SetupBeamPoints(VecMe, VecMeNew, g_Ruina_BEAM_Laser, 0, 0, 0, 0.15, ClampBeamWidth(diameter * 0.4 * 1.28), ClampBeamWidth(diameter * 0.4 * 1.28), 0, 1.0, {255,255,255,233}, 3);
				TE_SendToAll(0.0);
				if(IsValidEntity(npc.m_iWearable5))
				{
					RemoveEntity(npc.m_iWearable5);
				}
			}
		}
		else if(TimeLeft <= 3.1)
		{
			//Point To Target
			if(!IsValidEnemy(npc.index, npc.m_iTargetWalkTo, true, true))
			{
				if(IsValidEntity(npc.m_iWearable5))
				{
					RemoveEntity(npc.m_iWearable5);
				}
				npc.m_iTargetWalkTo = GetClosestTarget(npc.index);
				//get the next valid enemy
				npc.m_iChanged_WalkCycle = 0;
				if(npc.m_iTargetWalkTo == -1)
				{
					//no valid target, end ability now
					TimeLeft = 0.0;
				}
			}
			if(IsValidEnemy(npc.index, npc.m_iTargetWalkTo, true, true))
			{
				float VecEnemy[3]; WorldSpaceCenter(npc.m_iTargetWalkTo, VecEnemy);
				npc.FaceTowards(VecEnemy, 15000.0);
			}

			if(npc.m_iChanged_WalkCycle != 2) 	
			{
				if(IsValidEntity(npc.m_iWearable5))
				{
					RemoveEntity(npc.m_iWearable5);
				}
				npc.m_iWearable5 = ConnectWithBeam(npc.index, npc.m_iTargetWalkTo, 255, 0, 0, 5.0, 1.0, 0.0, LASERBEAM, .attachment1 = "point_particle");
				npc.PlayAimAtEnemy(npc.m_iTargetWalkTo);
				npc.m_bisWalking = false;
				npc.m_iChanged_WalkCycle = 2;
			//	npc.SetActivity("ACT_SHADOW_RUN");
				npc.m_flSpeed = 0.0;
				npc.StopPathing();
				
			}
		}
		return true;
	}
	return false;
}



bool Shadowing_Darkness_CreateRing(Shadowing_Darkness_Boss npc, float gameTime)
{
	if(npc.m_flCreateRingCD < gameTime && npc.m_iState == 0)
	{
		npc.m_flCreateRingCD = gameTime + 50.0;
		npc.m_iState = 4;	
		npc.m_flDoingAnimation = gameTime + 4.5;
		if(npc.m_iChanged_WalkCycle != 1) 	
		{
			npc.m_bisWalking = false;
			npc.m_iChanged_WalkCycle = 1;
			npc.SetActivity("ACT_SHADOW_CIRCLE_START");
			npc.m_flSpeed = 0.0;
			npc.StopPathing();
		}
		float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
		float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
		npc.m_flDespawnUmbralKoulms = gameTime + 10.0;
		static float flOldPos[3]; 
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flOldPos);
		flOldPos[2] += 5.0;
		ParticleEffectAt(flOldPos, "utaunt_poweraura_teamcolor_red", 4.5);
		npc.PlaySummonUmbrals();
		for(int loop=1; loop<=4; loop++)
		{
			int spawn_index = NPC_CreateByName("npc_umbral_koulm", -1, pos, ang, GetTeam(npc.index));
			if(spawn_index > MaxClients)
			{
				NpcAddedToZombiesLeftCurrently(spawn_index, true);
				SetEntProp(spawn_index, Prop_Data, "m_iHealth", (ReturnEntityMaxHealth(npc.index) / 8));
				SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", (ReturnEntityMaxHealth(npc.index) / 8));
				fl_Extra_Damage[spawn_index] *= 5.0;
				//10% dmg buff
			}
		}
		npc.m_iShadowingLeftSlice = 3;
		npc.m_iTargetWalkTo = npc.m_iTarget;
	}

	if(npc.m_iState == 4)
	{
		float TimeLeft = npc.m_flDoingAnimation - gameTime;
		if(TimeLeft <= 0.0)
		{
			//Reset back to normal, we are done.
			npc.m_iTargetWalkTo = 0;
			npc.m_iState = 0;
			npc.m_flRestoreDefaultWalk = 1.0;
		}
		else if(TimeLeft <= 0.5)
		{
			if(npc.m_iChanged_WalkCycle != 3) 	
			{
				//failed, cancel.
				npc.m_bisWalking = false;
				npc.m_iChanged_WalkCycle = 3;
				npc.SetActivity("ACT_SHADOW_CIRCLE_END");
				npc.m_flSpeed = 0.0;
				npc.StopPathing();
			}
		}
		else if(TimeLeft <= 2.5)
		{
			float CircleSize = 800.0; //,max size
			CircleSize *= ((((TimeLeft - 0.5) / 2.0) -1.0) * -1.0);
			Explode_Logic_Custom(0.0, 0, npc.index, -1, _, CircleSize, 1.0, _, true, 99,_,_,_,Shadowing_MarkedTarget_For_Slashing);
			float AbsVecMe[3];
			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", AbsVecMe);
			spawnRing_Vectors(AbsVecMe, CircleSize * 2.0, 0.0, 0.0, 5.0, "materials/sprites/combineball_trail_black_1.vmt", 255, 125, 125, 255, 1, 0.15, 30.0, 3.0, 2);
			npc.PlayCircleExpand();
			if(npc.m_iChanged_WalkCycle != 2) 	
			{
				npc.m_bisWalking = false;
				npc.m_iChanged_WalkCycle = 2;
				npc.SetActivity("ACT_SHADOW_CIRCLE_LOOP");
				npc.m_flSpeed = 0.0;
				npc.StopPathing();
				//change anim, expand circle
			}
		}
		else 
		{
			npc.PlayChargeCircle();
			float CircleSize = 800.0; //,max size
			CircleSize *= (TimeLeft - 3.0);
			float AbsVecMe[3];
			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", AbsVecMe);
			spawnRing_Vectors(AbsVecMe, CircleSize * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laser.vmt", 125, 125, 125, 255, 1, 0.15, 30.0, 0.0, 2);
		}
		return true;
	}
	return false;
}


float Shadowing_MarkedTarget_For_Slashing(int entity, int victim, float damage, int weapon)
{
	ApplyStatusEffect(entity, victim, "Kolum's View", 5.0);
	return damage;
}



float Shadowing_GiveNecrosis(int entity, int victim, float damage, int weapon)
{
	Elemental_AddNecrosisDamage(victim, entity, RoundToCeil(RaidModeScaling * 15.0));
	return damage;
}



public Action ShadowingDarkness_NecroPoolTimer(Handle timer, DataPack pack)
{
	pack.Reset();
	int Originator = EntRefToEntIndex(pack.ReadCell());
	int Particle = EntRefToEntIndex(pack.ReadCell());
	int Currentat = pack.ReadCell();
	if(IsValidEntity(Originator) && IsValidEntity(Particle))
	{
		Shadowing_Darkness_Boss npc = view_as<Shadowing_Darkness_Boss>(Originator);
		if(npc.m_iAtCurrentIntervalOfNecroArea != Currentat)
		{
			if(IsValidEntity(Particle))
				RemoveEntity(Particle);
			return Plugin_Stop;
		}

		float CircleSize = 150.0;
		float VecMe[3];
		GetEntPropVector(Particle, Prop_Data, "m_vecAbsOrigin", VecMe);
		VecMe[2] += 5.0;
		spawnRing_Vectors(VecMe, CircleSize * 2.0, 0.0, 0.0, 0.0, "materials/sprites/halo01.vmt", 255, 125, 125, 255, 1, 0.51, 15.0, 0.0, 2);
		Explode_Logic_Custom(0.0, 0, npc.index, -1, VecMe, CircleSize, 1.0, _, true, 99,_,_,_,Shadowing_GiveNecrosis);
	
		return Plugin_Continue;
	}
	else
	{
		if(IsValidEntity(Particle))
			RemoveEntity(Particle);
		
		return Plugin_Stop;
	}
}



bool Shadowing_Darkness_StatueTeleport(Shadowing_Darkness_Boss npc, float gameTime)
{
	if(npc.m_flTeleportToStatueCD < gameTime && npc.m_iState == 0)
	{
		npc.m_flTeleportToStatueCD = gameTime + 45.0;
		npc.m_iState = 5;	
		npc.m_flDoingAnimation = gameTime + 1.0;
		if(npc.m_iChanged_WalkCycle != 1) 	
		{
			npc.m_bisWalking = false;
			npc.m_iChanged_WalkCycle = 1;
			npc.SetActivity("ACT_SHADOW_IDLE_VOICE");
			npc.m_flSpeed = 0.0;
			npc.StopPathing();
		}
		
		//delete all koulms
		int victims;
		int[] victim = new int[MaxClients];
		int inpcloop, a;
		while((inpcloop = FindEntityByNPC(a)) != -1)
		{
			if(IsValidEntity(inpcloop) && i_NpcInternalId[inpcloop] == Umbral_Automaton_ID())
			{
				victim[victims++] = inpcloop;
			}
		}
		if(victims)
		{
			int winner = victim[GetURandomInt() % victims];
			npc.m_iTargetWalkTo = winner;
		}
	}

	if(npc.m_iState == 5)
	{
		float TimeLeft = npc.m_flDoingAnimation - gameTime;
		if(TimeLeft <= 0.0)
		{
			//Reset back to normal, we are done.
			if(IsValidEntity(npc.m_iTargetWalkTo))
			{
				static float flOldPos[3]; 
				GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flOldPos);
				flOldPos[2] += 5.0;
				int PoolAidsParticle = ParticleEffectAt(flOldPos, "utaunt_wiggletube_teamcolor_red", 0.0);
				DataPack pack;
				CreateDataTimer(0.5, ShadowingDarkness_NecroPoolTimer, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
				pack.WriteCell(EntIndexToEntRef(npc.index));
				pack.WriteCell(EntIndexToEntRef(PoolAidsParticle));
				pack.WriteCell(npc.m_iAtCurrentIntervalOfNecroArea);

				float pos[3]; GetEntPropVector(npc.m_iTargetWalkTo, Prop_Data, "m_vecAbsOrigin", pos);
				float ang[3]; GetEntPropVector(npc.m_iTargetWalkTo, Prop_Data, "m_angRotation", ang);
				//teleport To them and get a new target
				npc.m_flGetClosestTargetTime = 0.0;
				TeleportEntity(npc.index, pos, ang, NULL_VECTOR);
				npc.PlayTeleportToAlly();
				ApplyStatusEffect(npc.index, npc.m_iTargetWalkTo, "Caffinated", 10.0);
			}
			npc.m_iTargetWalkTo = 0;
			npc.m_iState = 0;
			npc.m_flRestoreDefaultWalk = 1.0;
		}
		else if(TimeLeft <= 1.0)
		{
			if(IsValidEntity(npc.m_iTargetWalkTo))
			{
				float VecThem[3];
				float CircleSize = 90.0;
				GetEntPropVector(npc.m_iTargetWalkTo, Prop_Data, "m_vecAbsOrigin", VecThem);
				spawnRing_Vectors(VecThem, CircleSize * 2.0, 0.0, 0.0, 5.0, "materials/sprites/halo01.vmt", 255, 125, 125, 255, 1, 0.15, 15.0, 0.0, 2);
				spawnRing_Vectors(VecThem, CircleSize * 2.0, 0.0, 0.0, 55.0, "materials/sprites/halo01.vmt", 255, 125, 125, 255, 1, 0.15, 15.0, 0.0, 2);
				spawnRing_Vectors(VecThem, CircleSize * 2.0, 0.0, 0.0, 105.0, "materials/sprites/halo01.vmt", 255, 125, 125, 255, 1, 0.15, 15.0, 0.0, 2);
				
				float VecMe[3];
				CircleSize = 40.0;
				GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", VecMe);
				spawnRing_Vectors(VecMe, CircleSize * 2.0, 0.0, 0.0, 5.0, "materials/sprites/halo01.vmt", 255, 125, 125, 255, 1, 0.15, 15.0, 0.0, 2);
				spawnRing_Vectors(VecMe, CircleSize * 2.0, 0.0, 0.0, 35.0, "materials/sprites/halo01.vmt", 255, 125, 125, 255, 1, 0.15, 15.0, 0.0, 2);
				spawnRing_Vectors(VecMe, CircleSize * 2.0, 0.0, 0.0, 65.0, "materials/sprites/halo01.vmt", 255, 125, 125, 255, 1, 0.15, 15.0, 0.0, 2);
				
				int r = 255;
				int g = 125;
				int b = 125;
				float diameter = 15.0;
				int colorLayer4[4];
				SetColorRGBA(colorLayer4, r, g, b, 233);
				VecThem[2] += 75.0;
				VecMe[2] += 45.0;
				TE_SetupBeamPoints(VecMe, VecThem, g_Ruina_BEAM_Laser, 0, 0, 0, 0.15, ClampBeamWidth(diameter * 0.1 * 1.28), ClampBeamWidth(diameter * 0.1 * 1.28), 0, 1.0, colorLayer4, 3);
				TE_SendToAll(0.0);
			}
			else
			{
				npc.m_iTargetWalkTo = 0;
				npc.m_flDoingAnimation = 0.0;
				//cancel.
			}
		}
		return true;
	}
	return false;
}



bool Shadowing_Darkness_TalkStart(Shadowing_Darkness_Boss npc)
{
	float TimeLeft = f_khamlCutscene - GetGameTime();

	switch(i_khamlCutscene)
	{
		case 15:
		{
			if(TimeLeft < 50.0)
			{
				MusicEnum music;
				strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/rogue3/shadowing_darkness.mp3");
				music.Time = 210;
				music.Volume = 1.35;
				music.Custom = true;
				strcopy(music.Name, sizeof(music.Name), "Burnt Light");
				strcopy(music.Artist, sizeof(music.Artist), "NeboScrub");
				Music_SetRaidMusic(music, false);
				i_khamlCutscene = 14;
				CPrintToChatAll("{darkgray}Shadowing Darkness{default}: Oh look how they have come to me...");
			}
		}
		case 14:
		{
			if(TimeLeft < 47.0)
			{
				i_khamlCutscene = 13;
				CPrintToChatAll("{darkgray}Shadowing Darkness{default}: How many umbrals did you piss off?");
			}
		}
		case 13:
		{
			if(TimeLeft < 43.0)
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
					{
						if(Rogue_HasNamedArtifact("Omega's Assistance"))
							CPrintToChatAll("{gold}Omega{default}: None of your business.");
						else
							CPrintToChatAll("{darkgray}Shadowing Darkness{default}: Better hope they are on your side, as for the void...");
					}
					case 1:
					{
						if(Rogue_HasNamedArtifact("Vhxis' Assistance"))
							CPrintToChatAll("{purple}Vhxis{default}: %i."), GetRandomInt(0, 100);
						else
							CPrintToChatAll("{darkgray}Shadowing Darkness{default}: Better hope they are on your side, as for the void...");
					}
				}
				i_khamlCutscene = 12;
			}
		}
		case 12:
		{
			if(TimeLeft < 40.0)
			{
				if(Rogue_HasNamedArtifact("Omega's Assistance"))
					CPrintToChatAll("{darkgray}Shadowing Darkness{default}: That was a rhetorical question...regardless, killing me won't stop the voids.");
				else
					CPrintToChatAll("{darkgray}Shadowing Darkness{default}: If you really think killing me will stop the voids, be my guest.");
				i_khamlCutscene = 11;
			}
		}
		case 11:
		{
			if(TimeLeft < 38.0)
			{
				if(Rogue_HasNamedArtifact("Omega's Assistance"))
				{
					CPrintToChatAll("{white}Bob{allies} & {gold}Omega{default}: Traitors.");
					CPrintToChatAll("{darkgray}Shadowing Darkness{default}: Me, a traitor? I didn't do anything.");
				}
				else
				{
					CPrintToChatAll("{white}Bob{default}: You and whiteflower are the most nasty traitors I have seen.");
					CPrintToChatAll("{darkgray}Shadowing Darkness{default}: Me, a traitor? I didn't do anything.");
				}
				i_khamlCutscene = 10;
			}
		}
		case 10:
		{
			if(TimeLeft < 34.0)
			{
				i_khamlCutscene = 9;
				if(Rogue_HasNamedArtifact("Bob's Wrath"))
					CPrintToChatAll("{white}Bob{crimson}: You killed Guln.");
				else
					CPrintToChatAll("{white}Bob{default}: I have yet to see where Guln ended up.");
			}
		}
		case 9:
		{
			if(TimeLeft < 30.0)
			{
				i_khamlCutscene = 8;
				if(Rogue_HasNamedArtifact("Bob's Wrath"))
					CPrintToChatAll("{darkgray}Shadowing Darkness{default}: Guln is dead..? ........");
				else
					CPrintToChatAll("{darkgray}Shadowing Darkness{default}: I don't know excatly what happend to Guln, I have tried to find him myself.");
			}
		}
		case 8:
		{
			if(TimeLeft < 25.0)
			{
				i_khamlCutscene = 7;
				CPrintToChatAll("{darkgray}Shadowing Darkness{default}: Whiteflower was not a bad person, however.... If you want to stop the void, you'll have to get ahold of the umbrals and make them do their job.");
			}
		}
		case 7:
		{
			if(TimeLeft < 23.0)
			{
				if(Rogue_HasNamedArtifact("Omega's Assistance"))
					CPrintToChatAll("{gold}Omega{default}: Whiteflower, not a bad person? You are deluded. You have to be taken out.");
				else
					CPrintToChatAll("{darkgray}Shadowing Darkness{default}: This is what the throne does, to a limited degree, and im atop of it, but...");
				i_khamlCutscene = 6;
			}
		}
		case 6:
		{
			if(TimeLeft < 18.0)
			{
				if(Rogue_HasNamedArtifact("Vhxis' Assistance"))
				{
					CPrintToChatAll("{purple}Vhxis{default}: Well, unless she wants to step down from the throne willingly, I think we'll have to take her out anyway.");
					CPrintToChatAll("{purple}Vhxis{default}: I'm sure this place will be better off with someone actually competent on the throne.");
				}
				else
					CPrintToChatAll("{darkgray}Shadowing Darkness{default}: Ever since i sat upon it, i wanted to do something else.");
				i_khamlCutscene = 5;
			}
		}
		case 5:
		{
			if(TimeLeft < 13.0)
			{
				if(Rogue_HasNamedArtifact("Vhxis' Assistance"))
					CPrintToChatAll("{darkgray}Shadowing Darkness{default}: Oh please, we all know I won't let anyone be the new heir to the throne.");
				else
					CPrintToChatAll("{darkgray}Shadowing Darkness{default}: Izan... i remember when you wanted to be a fake bob, that was hillarious.");
				i_khamlCutscene = 4;
			}
		}
		case 4:
		{
			if(TimeLeft < 8.0)
			{
				i_khamlCutscene = 3;
				CPrintToChatAll("{darkgray}Shadowing Darkness{default}: Then I'll be what unspeakable was, but reasonable, don't you think?");
			}
		}
		case 3:
		{
			if(TimeLeft < 4.0)
			{
				i_khamlCutscene = 2;
				CPrintToChatAll("{darkgray}Shadowing Darkness{default}: Who am I kidding, unspeakable is dead, luckily.");
			}
		}
		case 2:
		{
			if(TimeLeft < 1.5)
			{
				i_khamlCutscene = 1;
				npc.SetActivity("ACT_SHADOW_IDLE_START_TRANSITION");
				npc.m_flSpawnStatueUmbrals = 0.0;
				ShadowingDarkness_SpawnStatues(npc, "giant_shadow_statue_4");
				ShadowingDarkness_SpawnStatues(npc, "giant_shadow_statue_3");
			}
		}
		case 1:
		{
			if(TimeLeft < 0.0)
			{
				i_khamlCutscene = 0;
				CPrintToChatAll("{darkgray}Shadowing Darkness{default}: Let's make sure that the vision will finally come true, all under one, together, and as a collective~");
				RaidModeTime = GetGameTime() + (350.0);
				npc.m_flSwordParticleAttackCD = GetGameTime() + 10.0;
				npc.m_flPortalSummonGate = GetGameTime() + 25.0;
				npc.m_flUpperSlashCD = GetGameTime() + 15.0;
				npc.m_flCreateRingCD = GetGameTime() + 30.0;
				npc.m_flTeleportToStatueCD = GetGameTime() + 25.0;
				npc.SetActivity("ACT_SHADOW_RUN");
				npc.m_bisWalking = true;
				b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = false;
			}
		}
	}
	if(TimeLeft > 0.0)
	{
		ApplyStatusEffect(npc.index, npc.index, "Unstoppable Force", 0.5);
		return true;
	}
	return false;
}


void ShadowingDarkness_SpawnStatues(Shadowing_Darkness_Boss npc, const char[] data)
{
	float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
	int summon = NPC_CreateByName("npc_umbral_automaton", -1, pos, {0.0,0.0,0.0}, GetTeam(npc.index), data);
	if(IsValidEntity(summon))
	{
		if(GetTeam(npc.index) != TFTeam_Red)
			Zombies_Currently_Still_Ongoing++;

		SetEntProp(summon, Prop_Data, "m_iHealth", ReturnEntityMaxHealth(npc.index)/2);
		SetEntProp(summon, Prop_Data, "m_iMaxHealth", ReturnEntityMaxHealth(npc.index)/2);
		NpcStats_CopyStats(npc.index, summon);
		if(!data[0])
			TeleportDiversioToRandLocation(summon,_,3000.0, 500.0);
	}
}
