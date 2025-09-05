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
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Shadowing Darkness, the ruler");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_shadowing_darkness_boss");
	strcopy(data.Icon, sizeof(data.Icon), "shadowing_darkness");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = 0;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
}

static void ClotPrecache()
{

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

	public Shadowing_Darkness_Boss(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Shadowing_Darkness_Boss npc = view_as<Shadowing_Darkness_Boss>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_2_MODEL, "1.15", "300", ally, false,_,_,_,_));

		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");			
		i_NpcWeight[npc.index] = 5;

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		KillFeed_SetKillIcon(npc.index, "sword");

		npc.SetActivity("ACT_WHITEFLOWER_IDLE");

		npc.m_bisWalking = false;

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_bDissapearOnDeath = false;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;

		f3_SpawnPosition[npc.index][0] = vecPos[0];
		f3_SpawnPosition[npc.index][1] = vecPos[1];
		f3_SpawnPosition[npc.index][2] = vecPos[2];	

		

		bool final = StrContains(data, "final_item") != -1;
		
		if(final)
		{
			i_RaidGrantExtra[npc.index] = 1;
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
		RaidModeTime = GetGameTime() + (300.0);
		MusicEnum music;
		strcopy(music.Path, sizeof(music.Path), "#rpg_fortress/music/combine_elite_iberia_grandpabard.mp3");
		music.Time = 187;
		music.Volume = 1.0;
		music.Custom = true;
		strcopy(music.Name, sizeof(music.Name), "Iberia's Last Stand");
		strcopy(music.Artist, sizeof(music.Artist), "Grandpa Bard");
		Music_SetRaidMusic(music);

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

		RaidModeScaling *= 0.7;
		RaidModeScaling *= 1.85;

		RaidBossActive = EntIndexToEntRef(npc.index);
		RaidAllowsBuildings = false;
		Citizen_MiniBossSpawn();

		func_NPCDeath[npc.index] = Shadowing_Darkness_Boss_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Shadowing_Darkness_Boss_OnTakeDamage;
		func_NPCThink[npc.index] = Shadowing_Darkness_Boss_ClotThink;

		b_thisNpcIsARaid[npc.index] = true;
		b_thisNpcIsABoss[npc.index] = true;

		func_NPCFuncWin[npc.index] = view_as<Function>(Shadowing_DarknessWinLine);
		
	
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
	CPrintToChatAll("{darkgray}Shadowing Darkness{default}: Oh dont worry, i wont kill you\nI'll make sure that you understand what beauty this place is.");	
}

public void Shadowing_Darkness_Boss_ClotThink(int iNPC)
{
	Shadowing_Darkness_Boss npc = view_as<Shadowing_Darkness_Boss>(iNPC);

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
	if(RoundToCeil(damage) > Health)
	{	
		if(i_RaidGrantExtra[npc.index] == 1)
			CPrintToChatAll("{darkgray}Shadowing Darkness{default}: I am placeholder text, fix me.");	

		return Plugin_Changed;
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
	if(i_RaidGrantExtra[npc.index] == 1)
		CPrintToChatAll("{darkgray}Shadowing Darkness{default}: I am placeholder text, fix me.");	
		
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
					float damageDealt = 45.0;
					damageDealt *= RaidModeScaling;
					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);

					//they will give Necrosis damage.
					Elemental_AddNecrosisDamage(target, npc.index, RoundToCeil(damageDealt * 0.5));

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
				npc.AddGesture("ACT_WHITEFLOWER_ATTACK_RIGHT",_,_,_,2.5);
				npc.m_flAttackHappens = gameTime + 0.1;
				npc.m_flDoingAnimation = gameTime + 0.1;
				npc.m_flNextMeleeAttack = gameTime + 0.3;
			}
		}
	}
}

#define SD_PROJ_SPEED 1400.0
bool Shadowing_Darkness_SwordParticleAttack(Shadowing_Darkness_Boss npc, float gameTime)
{

	if(npc.m_flSwordParticleAttackCD < gameTime)
	{
		npc.m_flSwordParticleAttackCD = gameTime + 30.0;
		npc.m_iState = 1;
		npc.m_flDoingAnimation = gameTime + 2.0;
		if(npc.m_iChanged_WalkCycle != 1) 	
		{
			npc.m_bisWalking = false;
			npc.m_iChanged_WalkCycle = 1;
			npc.SetActivity("ACT_RUN");
			npc.m_flSpeed = 0.0;
			npc.StopPathing();
		}
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
			if(npc.m_iChanged_WalkCycle != 3) 	
			{
				npc.m_bisWalking = false;
				npc.m_iChanged_WalkCycle = 3;
				npc.SetActivity("ACT_RUN");
				npc.m_flSpeed = 0.0;
				npc.StopPathing();
			}
		}
		else if(TimeLeft <= 1.0)
		{
			//do whatever after some time
			if(npc.m_iChanged_WalkCycle != 2) 	
			{
				npc.m_bisWalking = false;
				npc.m_iChanged_WalkCycle = 2;
				npc.SetActivity("ACT_RUN");
				npc.m_flSpeed = 0.0;
				npc.StopPathing();

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
					int projectile = npc.FireProjectile_SD(vecSelf, vecAnglesLoop,  280.0 , 0.0, "raygun_projectile_blue");
					SD_ProjectileToEnemy(projectile, vecTargetProj, vecAnglesLoop, VecSpeed, EndPos);
					DataPack pack = new DataPack();
					pack.WriteCell(EntIndexToEntRef(projectile));
					pack.WriteFloat(VecSpeed[0]);
					pack.WriteFloat(VecSpeed[1]);
					pack.WriteFloat(VecSpeed[2]);
					RequestFrames(SD_ProjectileGiveSpeed, (loop * 2), pack);
					WorldSpaceCenter(projectile, vecSelf);

					TE_SetupBeamPoints(vecSelf, EndPos, Shared_BEAM_Laser, 0, 0, 0, 1.5, 3.0, 3.0, 0, 0.0, {0,0,255,125}, 3);
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

#define MAX_BOUNCES_SHADOWING_DARKNESS 4
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
	TE_SetupBeamPoints(vecSelf, EndPos, Shared_BEAM_Laser, 0, 0, 0, 1.5, 3.0, 3.0, 0, 0.0, {0,0,255,125}, 3);
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