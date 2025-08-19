#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"ui/killsound_squasher.wav",
};

static const char g_HurtSounds[][] = {
	"ui/hitsound_vortex1.wav",
	"ui/hitsound_vortex2.wav",
	"ui/hitsound_vortex3.wav",
	"ui/hitsound_vortex4.wav",
	"ui/hitsound_vortex5.wav",
};

static const char g_IdleAlertedSounds[][] = {
	"doors/door_metal_rusty_move1.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"npc/attack_helicopter/aheli_charge_up.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/capper_shoot.wav",
};

static int NPCId;

int Umbral_Koulm_ID()
{
	return NPCId;
}

void Umbral_Koulm_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	PrecacheModel("models/player/sniper.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Umbral Koulm");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_umbral_koulm");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Mutation;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Umbral_Koulm(vecPos, vecAng, team);
}
methodmap Umbral_Koulm < CClotBody
{
	property float m_flSpassOut
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flSpassOut2
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property float m_flTeleportRandomly
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	property float m_flBuffeveryoneTimer
	{
		public get()							{ return fl_AbilityOrAttack[this.index][4]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][4] = TempValueForProperty; }
	}
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;

		if(this.m_flSpassOut > GetGameTime(this.index))
			return;

		this.m_flNextIdleSound = GetGameTime(this.index) + 1.0;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, 1.0, GetRandomInt(35, 40));
		
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.3;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, 1.0, GetRandomInt(40, 60));
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 50);
	}
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 150);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 60);
	}
	
	public Umbral_Koulm(float vecPos[3], float vecAng[3], int ally)
	{
		Umbral_Koulm npc = view_as<Umbral_Koulm>(CClotBody(vecPos, vecAng, "models/player/sniper.mdl", "1.5", "22500", ally, .isGiant = true));
		
		i_NpcWeight[npc.index] = 5;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		SetVariantInt(2);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		//counts as a static npc, means it wont count towards NPC limit.
		AddNpcToAliveList(npc.index, 1);
		
		npc.AddActivityViaSequence("layer_taunt_yeti_prop");
		npc.SetPlaybackRate(0.0);
		npc.SetCycle(0.06);
		npc.m_bisWalking = false; 
		npc.m_flNextMeleeAttack = 0.0;
		fl_GetClosestTargetTimeTouch[npc.index] = FAR_FUTURE;
		
		npc.m_iBleedType = BLEEDTYPE_UMBRAL;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;

		func_NPCDeath[npc.index] = view_as<Function>(Umbral_Koulm_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Umbral_Koulm_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Umbral_Koulm_ClotThink);
		
		npc.StopPathing();
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		npc.m_flGravityMulti = 1.0;

		npc.m_bDissapearOnDeath = true;
		TeleportDiversioToRandLocation(npc.index,_,2000.0, 1250.0);
		//dont allow self making
		
		npc.m_flSpeed = 0.0;

		SetEntityRenderFx(npc.index, RENDERFX_EXPLODE);
		SetEntityRenderColor(npc.index, GetRandomInt(25, 35), GetRandomInt(25, 35), GetRandomInt(25, 35), 255);

		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/spy/sum24_tuxedo_royale_style1/sum24_tuxedo_royale_style1.mdl");
		SetEntityRenderFx(npc.m_iWearable1, RENDERFX_EXPLODE);
		SetEntityRenderColor(npc.m_iWearable1, GetRandomInt(25, 35), GetRandomInt(25, 35), GetRandomInt(25, 35), 255);

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/pyro/hw2013_rugged_respirator/hw2013_rugged_respirator.mdl");
		SetEntityRenderFx(npc.m_iWearable2, RENDERFX_EXPLODE);
		SetEntityRenderColor(npc.m_iWearable2, GetRandomInt(25, 35), GetRandomInt(25, 35), GetRandomInt(25, 35), 255);

		

		return npc;
	}
}

public void Umbral_Koulm_ClotThink(int iNPC)
{
	Umbral_Koulm npc = view_as<Umbral_Koulm>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
	//	npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
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
		npc.m_iTarget = GetClosestTarget(npc.index, .UseVectorDistance = true, .ExtraValidityFunction = Kolum_AttackOnly);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + 0.5;
	}
	UmbralKoulmRandomlyTeleport(npc);

	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		if(!HasSpecificBuff(npc.m_iTarget, "Kolum's View"))
		{
			npc.m_iTarget = 0;
			return;
		}
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		Umbral_KoulmSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
		UmbralKoulmAnimBreak(npc);
	}

	npc.PlayIdleAlertSound();
}

bool Kolum_AttackOnly(int entity, int target)
{
	if(HasSpecificBuff(target, "Kolum's View"))
	{
		return true;
	}
	return false;
}
public Action Umbral_Koulm_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Umbral_Koulm npc = view_as<Umbral_Koulm>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}

	int maxhealth = ReturnEntityMaxHealth(npc.index);
	int CurrentHealth = GetEntProp(npc.index, Prop_Data, "m_iHealth");
	if(float(maxhealth) * 0.9 > float(CurrentHealth))
	{
		ApplyStatusEffect(victim, attacker, "Kolum's View", 7.5);
	}
	
	return Plugin_Changed;
}

public void Umbral_Koulm_NPCDeath(int entity)
{
	Umbral_Koulm npc = view_as<Umbral_Koulm>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
		
	StopSound(npc.index, SNDCHAN_VOICE, g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)]);
	float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
		
	TE_Particle("pyro_blast", WorldSpaceVec, NULL_VECTOR, 		{90.0,0.0,0.0}, -1, _, _, _, _, _, _, _, _, _, 0.0);
	TE_Particle("pyro_blast_warp", WorldSpaceVec, NULL_VECTOR, 	{90.0,0.0,0.0}, -1, _, _, _, _, _, _, _, _, _, 0.0);
	TE_Particle("pyro_blast_flash", WorldSpaceVec, NULL_VECTOR, {90.0,0.0,0.0}, -1, _, _, _, _, _, _, _, _, _, 0.0);

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

void Umbral_KoulmSelfDefense(Umbral_Koulm npc, float gameTime, int target, float distance)
{
	if(npc.m_flAttackHappens)
	{
		float origin[3];
		float angles[3];
		npc.GetAttachment("eyeglow_R", origin, angles);
		float VecEnemy[3]; WorldSpaceCenter(target, VecEnemy);
		npc.FaceTowards(VecEnemy, 15000.0);
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			if(Can_I_See_Enemy_Only(npc.index, target)) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
			{	
				npc.PlayMeleeHitSound();
				TE_SetupBeamPoints(origin, VecEnemy, Shared_BEAM_Laser, 0, 0, 0, 0.12, 5.0, 6.0, 0, 0.0, {200,200,200,255}, 3);
				TE_SendToAll(0.0);
				float damageDealt = 400.0;
				if(ShouldNpcDealBonusDamage(target))
					damageDealt *= 3.0;


				SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_BULLET, -1, _, VecEnemy);
			}
		}
		else
		{
			if(Can_I_See_Enemy_Only(npc.index, target)) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
			{	
				TE_SetupBeamPoints(origin, VecEnemy, Shared_BEAM_Laser, 0, 0, 0, 0.12, 5.0, 6.0, 0, 1.0, {100,100,100,200}, 3);
				TE_SendToAll(0.0);
			}
		}
	}

	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(Can_I_See_Enemy_Only(npc.index, target))
		{
			npc.PlayMeleeSound();
		//	npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE",_,_,_,1.5);
			npc.m_flAttackHappens = gameTime + 0.2;
			npc.m_flDoingAnimation = gameTime + 0.2;
			npc.m_flNextMeleeAttack = gameTime + 0.55;
		}
	}
}



void UmbralKoulmAnimBreak(Umbral_Koulm npc)
{

	if(npc.m_flSpassOut < GetGameTime())
	{
		float Random = GetRandomFloat(0.4, 0.7);
		int Layer;
		npc.m_flSpassOut = GetGameTime() + (Random * 0.5);
		Layer = npc.AddGesture("ACT_KART_IMPACT_BIG", .SetGestureSpeed = (1.5 * (1.0 / Random)));
		npc.SetLayerWeight(Layer, 0.2);
		Layer = npc.AddGesture("ACT_GRAPPLE_PULL_START", .SetGestureSpeed = (1.5 * (1.0 / Random)));
		npc.SetLayerWeight(Layer, 0.1);
	}
	if(npc.m_flSpassOut2 < GetGameTime())
	{
		float Random = GetRandomFloat(0.4, 0.7);
		int Layer;
		npc.m_flSpassOut2 = GetGameTime() + (Random * 0.5);
		Layer = npc.AddGesture("ACT_MP_GESTURE_VC_HANDMOUTH_MELEE", .SetGestureSpeed = (1.5 * (1.0 / Random)));
		npc.SetLayerWeight(Layer, 0.1);
	}
}


void UmbralKoulmRandomlyTeleport(Umbral_Koulm npc)
{
	if(npc.m_flBuffeveryoneTimer < GetGameTime())
	{
		float BuffRange = 300.0;
		npc.m_flBuffeveryoneTimer = GetGameTime() + 0.5;
		float VecPos[3];
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", VecPos);
		spawnRing_Vectors(VecPos, BuffRange * 2.0, 0.0, 0.0, 15.0, "materials/sprites/laserbeam.vmt", /*R*/200, /*G*/200, /*B*/200, /*alpha*/100, 1, /*duration*/ 0.6, 20.0, 0.5, 2);
		b_NpcIsTeamkiller[npc.index] = true;
		b_AllowSelfTarget[npc.index] = true;
		Explode_Logic_Custom(0.0, npc.index, npc.index, -1, VecPos, BuffRange, _, _, false, 99, _, _, KoulmAreaBuff);
		b_NpcIsTeamkiller[npc.index] = false;
		b_AllowSelfTarget[npc.index] = false;
	}
	if(npc.m_flTeleportRandomly > GetGameTime(npc.index))
		return;

	npc.m_flTeleportRandomly = GetGameTime(npc.index) + 3.0;

	float VecPos[3];
	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", VecPos);
	VecPos[0] += (GetRandomInt(0, 1)) ? -60.0 : 60.0;
	VecPos[1] += (GetRandomInt(0, 1)) ? -60.0 : 60.0;
	
	static float hullcheckmaxs[3];
	static float hullcheckmins[3];
	hullcheckmaxs = view_as<float>( { 30.0, 30.0, 120.0 } );
	hullcheckmins = view_as<float>( { -30.0, -30.0, 0.0 } );

	bool Succeed = Npc_Teleport_Safe(npc.index, VecPos, hullcheckmins, hullcheckmaxs, true);
	if(!Succeed)
	{
		npc.m_flTeleportRandomly = GetGameTime(npc.index) + 0.2;
	}
	else
	{
		float vecAng[3];
		vecAng[0] = GetRandomFloat(-15.0,15.0);
		vecAng[1] = GetRandomFloat(-90.0,90.0);
		SetEntPropVector(npc.index, Prop_Data, "m_angRotation", vecAng);
	}
}



void KoulmAreaBuff(int attacker, int victim, float &damage, int weapon)
{
	if(i_NpcInternalId[victim] == Umbral_Koulm_ID())
		return;

	//grant the "buff"
	ApplyStatusEffect(attacker, victim, "Umbral Grace Debuff", 2.5);
	ApplyStatusEffect(attacker, victim, "Umbral Grace", 2.5);
}