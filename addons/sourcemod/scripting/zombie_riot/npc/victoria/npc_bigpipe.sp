#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/demoman_sf13_magic_reac03.mp3",
	"vo/demoman_sf13_magic_reac05.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/demoman_painsharp01.mp3",
	"vo/demoman_painsharp02.mp3",
	"vo/demoman_painsharp03.mp3",
	"vo/demoman_painsharp04.mp3",
	"vo/demoman_painsharp05.mp3",
	"vo/demoman_painsharp06.mp3",
	"vo/demoman_painsharp07.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/demoman_sf13_midnight02.mp3",
	"vo/demoman_sf13_midnight04.mp3",
	"vo/demoman_sf13_midnight05.mp3",
	"vo/demoman_sf13_midnight06.mp3",
};

static const char g_MeleeAttackSounds[][] = {
	"mvm/giant_demoman/giant_demoman_grenade_shoot.wav",
};

static const char g_ReloadSound[][] = {
	"weapons/ar2/npc_ar2_reload.wav",
};

static const char g_ExplosionSounds[][]= {
	"weapons/explode1.wav",
	"weapons/explode2.wav",
	"weapons/explode3.wav"
};

static int m_iGunType;


void VictoriaBigpipe_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_ExplosionSounds)); i++) { PrecacheSound(g_ExplosionSounds[i]); }
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Bigpipe");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_bigpipe");
	strcopy(data.Icon, sizeof(data.Icon), "big_pipe");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_Victoria;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static float fl_npc_basespeed;

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return VictoriaBigpipe(vecPos, vecAng, ally, data);
}

methodmap VictoriaBigpipe < CClotBody
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

	public void PlayReloadSound() 
	{
		EmitSoundToAll(g_ReloadSound[GetRandomInt(0, sizeof(g_ReloadSound) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}

	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayARSound()
	{
		EmitSoundToAll("weapons/ar2/fire1.wav", this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayGrenadeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME - 0.2);
	}
	property float m_flWeaponSwitchCooldown
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	
	public void SetWeaponModel(const char[] model, float Scale = 1.0)		//dynamic weapon model change, don't touch
	{
		if(IsValidEntity(this.m_iWearable1))
			RemoveEntity(this.m_iWearable1);
		
		if(model[0])
		{
			this.m_iWearable1 = this.EquipItem("head", model);
			if(Scale != 1.0)
			{
				char buffer[32];
				FormatEx(buffer, sizeof(buffer), "%.2f", Scale);
				SetVariantString(buffer);
				AcceptEntityInput(this.m_iWearable1, "SetModelScale");
			}
		}
	}
	
	public VictoriaBigpipe(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		VictoriaBigpipe npc = view_as<VictoriaBigpipe>(CClotBody(vecPos, vecAng, "models/player/demo.mdl", "1.0", "1250", ally,false));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.SetActivity("ACT_MP_RUN_SECONDARY");
			
		SetVariantInt(4);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		bool IconOnly = StrContains(data, "icononly") != -1;
		if(IconOnly)
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

		func_NPCDeath[npc.index] = view_as<Function>(VictoriaBigpipe_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(VictoriaBigpipe_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(VictoriaBigpipe_ClotThink);
		
		//IDLE
		npc.m_iState = 0;
		m_iGunType = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		npc.m_flSpeed = 180.0;
		fl_npc_basespeed = 180.0;
		npc.m_iOverlordComboAttack = 6;
		
		b_ThisNpcIsImmuneToNuke[npc.index] = true;
		GiveNpcOutLineLastOrBoss(npc.index, true);
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		npc.SetWeaponModel("models/weapons/c_models/c_grenadelauncher/c_grenadelauncher.mdl", 1.25);

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/soldier/sum19_dancing_doe/sum19_dancing_doe.mdl");
		SetVariantString("1.2");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/demo/demo_beardpipe_s2/demo_beardpipe_s2.mdl");

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/all_class/sum19_staplers_specs/sum19_staplers_specs_demo.mdl");
		SetVariantString("1.1");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/demo/hwn2023_mad_lad/hwn2023_mad_lad.mdl");

		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 3);
		SetEntityRenderColor(npc.m_iWearable1, 50, 150, 255, 255);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntityRenderColor(npc.m_iWearable2, 0, 0, 0, 255);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);

		return npc;
	}
}

public void VictoriaBigpipe_ClotThink(int iNPC)
{
	VictoriaBigpipe npc = view_as<VictoriaBigpipe>(iNPC);
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
	
	if(npc.m_iOverlordComboAttack < 1)
	{
		if(npc.m_iChanged_WalkCycle != 6)
		{
			npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 2.5;
			npc.m_bisWalking = true;
			npc.m_iChanged_WalkCycle = 6;
			npc.AddGesture("ACT_MP_RELOAD_STAND_SECONDARY", true,_,_,0.37);
			npc.m_flSpeed = 0.0;
			npc.StopPathing();
			npc.PlayReloadSound();
			npc.m_iOverlordComboAttack = 6;
		}
		return;
	}

	//Swtich modes depending on area.
	if(npc.m_flWeaponSwitchCooldown < GetGameTime(npc.index))
	{
		npc.m_flWeaponSwitchCooldown = GetGameTime(npc.index) + 5.0;
		static float flMyPos[3];
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flMyPos);
		static float hullcheckmaxs[3];
		static float hullcheckmins[3];

		//Defaults:
		//hullcheckmaxs = view_as<float>( { 24.0, 24.0, 72.0 } );
		//hullcheckmins = view_as<float>( { -24.0, -24.0, 0.0 } );

		hullcheckmaxs = view_as<float>( { 35.0, 35.0, 500.0 } ); //check if above is free
		hullcheckmins = view_as<float>( { -35.0, -35.0, 17.0 } );

		if(!IsSpaceOccupiedWorldOnly(flMyPos, hullcheckmins, hullcheckmaxs, npc.index))
		{
			if(npc.m_iChanged_WalkCycle != 1)
			{
				npc.m_bisWalking = true;
				npc.m_iChanged_WalkCycle = 1;
				npc.SetActivity("ACT_MP_RUN_SECONDARY");
				npc.StartPathing();
				npc.m_flSpeed = 275.0;
			}
		}
		else
		{
			if(npc.m_iChanged_WalkCycle != 2)
			{
				npc.m_bisWalking = true;
				npc.m_iChanged_WalkCycle = 2;
				npc.SetActivity("ACT_MP_RUN_SECONDARY");
				npc.StartPathing();
				npc.m_flSpeed = 310.0;
			}
		}
	}
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		int ActionDo = VictoriaBigpipeSelfDefense(npc,GetGameTime(npc.index), flDistanceToTarget); 
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
				npc.m_flSpeed = 200.0;
			}
			case 1:
			{
				npc.StopPathing();
				npc.m_flSpeed = 0.0;
				//Stand still.
			}
			case 2:
			{
				npc.StartPathing();
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
				npc.m_flSpeed = 300.0;
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

public Action VictoriaBigpipe_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VictoriaBigpipe npc = view_as<VictoriaBigpipe>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void VictoriaBigpipe_NPCDeath(int entity)
{
	VictoriaBigpipe npc = view_as<VictoriaBigpipe>(entity);
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

int VictoriaBigpipeSelfDefense(VictoriaBigpipe npc, float gameTime, float distance)
{
	//Direct mode
	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 20.0))
		{
			float VecAim[3]; WorldSpaceCenter(npc.m_iTarget, VecAim );
			npc.FaceTowards(VecAim, 20000.0);
			int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				float RocketSpeed = 1500.0;
				float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
				float VecStart[3]; WorldSpaceCenter(npc.index, VecStart );
				float vecDest[3];
				vecDest = vecTarget;
				vecDest[0] += GetRandomFloat(-50.0, 50.0);
				vecDest[1] += GetRandomFloat(-50.0, 50.0);
				if(npc.m_iChanged_WalkCycle == 1)
				{
					if(m_iGunType!=0)
					{
						npc.SetWeaponModel("models/weapons/c_models/c_grenadelauncher/c_grenadelauncher.mdl", 1.25);
						m_iGunType=0;
						SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 3);
						SetEntityRenderColor(npc.m_iWearable1, 50, 150, 255, 255);
					}
				
					float SpeedReturn[3];
					npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY");

					int RocketGet = npc.FireRocket(vecDest, 0.0, RocketSpeed, "models/weapons/w_models/w_grenade_grenadelauncher.mdl", 1.2);
					SDKHook(RocketGet, SDKHook_StartTouch, HEGrenade_StartTouch);
					SetEntProp(RocketGet, Prop_Send, "m_nSkin", 1);
					//Reducing gravity, reduces speed, lol.
					//SetEntityGravity(RocketGet, 1.0); 	
					//I dont care if its not too accurate, ig they suck with the weapon idk lol, lore.
					ArcToLocationViaSpeedProjectile(VecStart, vecDest, SpeedReturn, 1.75, 1.0);
					//SetEntityMoveType(RocketGet, MOVETYPE_FLYGRAVITY);
					TeleportEntity(RocketGet, NULL_VECTOR, NULL_VECTOR, SpeedReturn);
					Better_Gravity_Rocket(RocketGet, 55.0);

					//This will return vecTarget as the speed we need.
					npc.m_iOverlordComboAttack --;
					npc.m_flNextMeleeAttack = gameTime + 0.25;
					npc.PlayGrenadeSound();
				}
				else
				{
					int target = npc.m_iTarget;
					if(m_iGunType!=1)
					{
						npc.SetWeaponModel("models/weapons/c_models/c_tfc_sniperrifle/c_tfc_sniperrifle.mdl", 1.25);
						m_iGunType=1;
					}
					npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY",_,_,_,1.5);
					Handle swingTrace;
					if(npc.DoSwingTrace(swingTrace, target, { 9999.0, 9999.0, 9999.0 }))
					{
						target = TR_GetEntityIndex(swingTrace);	
							
						float vecHit[3];
						TR_GetEndPosition(vecHit, swingTrace);
						float origin[3], angles[3];
						view_as<CClotBody>(npc.index).GetAttachment("effect_hand_r", origin, angles);
						ShootLaser(npc.index, "bullet_tracer01_red", origin, vecHit, false );
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.1;
						if(IsValidEnemy(npc.index, target))
						{
							float damageDealt = 20.0;
							if(Waves_GetRoundScale()+1 > 8)
								damageDealt *= float(Waves_GetRoundScale()+1)*0.133333;
							if(ShouldNpcDealBonusDamage(target))
								damageDealt *= 3.0;

							SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_BULLET, -1, _, vecHit);
						}
						npc.PlayARSound();
					}
					delete swingTrace;
					return 2;
				}
			}
		}
	}
	if(npc.m_flNextMeleeAttack > gameTime)
	{
		npc.m_flSpeed = 0.0;
	}
	else
	{
		npc.m_flSpeed = fl_npc_basespeed;
	}
	//No can shooty.
	//Enemy is close enough.
	if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 15.0))
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

static Action HEGrenade_StartTouch(int entity, int target)
{
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if(!IsValidEntity(owner))
		owner = 0;
	int inflictor = h_ArrowInflictorRef[entity];
	if(inflictor != -1)
		inflictor = EntRefToEntIndex(h_ArrowInflictorRef[entity]);

	if(inflictor == -1)
		inflictor = owner;
		
	float ProjectileLoc[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);
	Explode_Logic_Custom(0.0, owner, inflictor, -1, ProjectileLoc, 146.0, _, _, true, _, false, _, HEGrenade);
	ParticleEffectAt(ProjectileLoc, "ExplosionCore_MidAir", 1.0);
	EmitSoundToAll(g_ExplosionSounds[GetRandomInt(0, sizeof(g_ExplosionSounds) - 1)], 0, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, _, -1, ProjectileLoc);
	RemoveEntity(entity);
	return Plugin_Handled;
}

static void HEGrenade(int entity, int victim, float damage, int weapon)
{
	float vecHit[3]; WorldSpaceCenter(victim, vecHit);
	if(GetTeam(entity) != GetTeam(victim))
	{
		int inflictor = h_ArrowInflictorRef[entity];
		if(inflictor != -1)
			inflictor = EntRefToEntIndex(h_ArrowInflictorRef[entity]);

		if(inflictor == -1)
			inflictor = entity;
		damage = 100.0;
		if(ShouldNpcDealBonusDamage(victim))
			damage *= 3.0;
		SDKHooks_TakeDamage(victim, entity, inflictor, damage, DMG_BLAST, -1, _, vecHit);
	}
}

public void Better_Gravity_Rocket(int entity, float gravity)
{
	DataPack GravityProjectile = new DataPack();
	GravityProjectile.WriteCell(EntIndexToEntRef(entity));
	GravityProjectile.WriteFloat(gravity);
	RequestFrame(GravityProjectileThink, GravityProjectile);
}
static void GravityProjectileThink(DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	float gravity = pack.ReadFloat();
	if(!IsValidEntity(entity))
		return;
	float vel[3],ang[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsVelocity", vel);
	vel[2] -= gravity;
	GetVectorAngles(vel, ang);
	SetEntPropVector(entity, Prop_Data, "m_vecAbsVelocity", vel);
	SetEntPropVector(entity, Prop_Data, "m_angRotation", ang);
	delete pack;
	DataPack pack2 = new DataPack();
	pack2.WriteCell(EntIndexToEntRef(entity));
	pack2.WriteFloat(gravity);
	float Throttle = 0.04;	//0.025
	int frames_offset = RoundToCeil(66.0*Throttle);	//no need to call this every frame if avoidable
	if(frames_offset < 0)
		frames_offset = 1;
	RequestFrames(GravityProjectileThink, frames_offset, pack2);
}