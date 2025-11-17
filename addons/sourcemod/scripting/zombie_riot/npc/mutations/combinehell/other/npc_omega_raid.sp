#pragma semicolon 1
#pragma newdecls required

static const char g_TeleDeathSound[][] = {
	"weapons/rescue_ranger_teleport_receive_01.wav",
	"weapons/rescue_ranger_teleport_receive_02.wav",
};

static const char g_DeathSounds[][] = {
	"npc/combine_soldier/die1.wav",
	"npc/combine_soldier/die2.wav",
	"npc/combine_soldier/die3.wav",
};

static const char g_HurtSounds[][] = {
	"npc/combine_soldier/pain1.wav",
	"npc/combine_soldier/pain2.wav",
	"npc/combine_soldier/pain3.wav",
};

static const char g_IdleAlertedSounds[][] = {
	"npc/combine_soldier/vo/alert1.wav",
	"npc/combine_soldier/vo/hardenthatposition.wav",
	"npc/combine_soldier/vo/overwatchreportspossiblehostiles.wav",
	"npc/combine_soldier/vo/readyweaponshostilesinbound.wav",
	"npc/combine_soldier/vo/swarmoutbreakinsector.wav",
	"npc/combine_soldier/vo/targetcompromisedmovein.wav",
	"npc/combine_soldier/vo/overwatchsectoroverrun.wav",
	"npc/combine_soldier/vo/contactconfim.wav",
	"npc/combine_soldier/vo/prosecuting.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"npc/vort/claw_swing1.wav",
	"npc/vort/claw_swing2.wav",
};

static const char g_MeleeHitSounds[][] = {
	"physics/body/body_medium_impact_hard1.wav",
	"physics/body/body_medium_impact_hard2.wav",
	"physics/body/body_medium_impact_hard3.wav",
	"physics/body/body_medium_impact_hard4.wav",
	"physics/body/body_medium_impact_hard5.wav",
	"physics/body/body_medium_impact_hard6.wav",
};

static const char g_BoomSounds[][] = {
	"weapons/mortar/mortar_explode1.wav",
	"weapons/mortar/mortar_explode2.wav",
	"weapons/mortar/mortar_explode3.wav",
};

static char g_PullSounds[][] = {
	"weapons/rpg/rocketfire1.wav",
};

/*
static const char g_MeleeComboSounds[][] = {
	"physics/body/body_medium_break2.wav",
	"physics/body/body_medium_break3.wav",
	"physics/body/body_medium_break4.wav",
};
*/

static const char g_MeleeStunSounds[][] = {
	"ambient/energy/zap5.wav",
	"ambient/energy/zap6.wav",
	"ambient/energy/zap9.wav",
};

/*
static const char g_SpecialAttackSounds[][] = {
	"npc/attack_helicopter/aheli_megabomb_siren1.wav",
	"npc/attack_helicopter/aheli_mine_drop1.wav",
};
*/

static char g_RangedAttackSounds[][] = {
	"npc/attack_helicopter/aheli_mine_drop1.wav",
};

static char g_RangedReloadSound[][] = {
	"weapons/revolver_worldreload.wav",
};

static int LastEnemyTargeted[MAXENTITIES];



static float f_TalkDelayCheck;
static int i_TalkDelayCheck;

static int NpcID;

int OmegaRaidNpcID()
{
	return NpcID;
}

void OmegaRaid_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_TeleDeathSound));	   i++) { PrecacheSound(g_TeleDeathSound[i]);	   }
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds));   i++) { PrecacheSound(g_RangedAttackSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedReloadSound));   i++) { PrecacheSound(g_RangedReloadSound[i]);   }
	for (int i = 0; i < (sizeof(g_MeleeStunSounds));   i++) { PrecacheSound(g_MeleeStunSounds[i]);   }
	for (int i = 0; i < (sizeof(g_BoomSounds));   i++) { PrecacheSound(g_BoomSounds[i]);   }
	for (int i = 0; i < (sizeof(g_PullSounds));   i++) { PrecacheSound(g_PullSounds[i]);   }
	PrecacheModel("models/combine_super_soldier.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Omega");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_omega_raid");
	strcopy(data.Icon, sizeof(data.Icon), "omega");
	PrecacheSound("#zombiesurvival/combinehell/cauterizer.mp3");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_Raid;
	data.Func = ClotSummon;
	NpcID = NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return OmegaRaid(vecPos, vecAng, ally, data);
}

methodmap OmegaRaid < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
	}

	public void PlayPullSound() {
		EmitSoundToAll(g_PullSounds[GetRandomInt(0, sizeof(g_PullSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
	}
	public void PlayTeleSound() {
		EmitSoundToAll(g_TeleDeathSound[GetRandomInt(0, sizeof(g_TeleDeathSound) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
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
	public void PlayMeleeStunSound() 
	{
		EmitSoundToAll(g_MeleeStunSounds[GetRandomInt(0, sizeof(g_MeleeStunSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);

	}
	public void PlayBoomSound() 
	{
		EmitSoundToAll(g_BoomSounds[GetRandomInt(0, sizeof(g_BoomSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);

	}
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, _, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 95);
		
	}
	public void PlayRangedReloadSound() {
		EmitSoundToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, _, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 95);
		
	}
	public void ArmorSet(float resistance = -1.0, bool uber = false)
	{
		if(resistance != -1.0 && resistance >= 0.0)
		{
			this.m_flMeleeArmor = resistance;
			this.m_flRangedArmor = resistance;
		}
		b_NpcIsInvulnerable[this.index] = uber;
	}

	property int i_GunMode
	{
		public get()							{ return i_TimesSummoned[this.index]; }
		public set(int TempValueForProperty) 	{ i_TimesSummoned[this.index] = TempValueForProperty; }
	}
	property float m_flOmegaAirbornAttack
	{
		public get()							{ return fl_AbilityOrAttack[this.index][4]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][4] = TempValueForProperty; }
	}
	property float m_flOmegaRPGCD
	{
		public get()							{ return fl_RangedSpecialDelay[this.index]; }
		public set(float TempValueForProperty) 	{ fl_RangedSpecialDelay[this.index] = TempValueForProperty; }
	}
	property float m_flOmegaRPGHappening
	{
		public get()							{ return fl_AttackHappens_2[this.index]; }
		public set(float TempValueForProperty) 	{ fl_AttackHappens_2[this.index] = TempValueForProperty; }
	}
	
	
	public OmegaRaid(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		OmegaRaid npc = view_as<OmegaRaid>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.25", "1000000", ally));

		bool item = StrContains(data, "item") != -1;
		if(item)
		{
			b_NpcUnableToDie[npc.index] = true;
			i_RaidGrantExtra[npc.index] = 5;
			npc.m_flSpeed = 250.0;
		}
		else
		{
			npc.m_bDissapearOnDeath = true;
			npc.m_flSpeed = 310.0;
		}
		
		i_NpcWeight[npc.index] = 5;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");

		RaidBossActive = EntIndexToEntRef(npc.index);
		RaidAllowsBuildings = false;
		
		int iActivity = npc.LookupActivity("ACT_BRAWLER_RUN");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iAttacksTillReload = 12;

		npc.m_fbGunout = false;

		func_NPCFuncWin[npc.index] = RaidMode_OmegaRaid_WinCondition;

		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;
		npc.m_flOmegaRPGCD = GetGameTime() + 6.0;
		i_TalkDelayCheck = -1;

		npc.m_iWearable2 = npc.EquipItem("head", "models/combine_super_soldier.mdl");
		npc.m_iWearable3 = npc.EquipItem("partyhat", "models/player/items/sniper/jarate_headband.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		npc.m_iWearable4 = npc.EquipItem("anim_attachment_RH", "models/weapons/w_rocket_launcher.mdl");
		AcceptEntityInput(npc.m_iWearable4, "Disable");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		SetVariantString("1.25");

		func_NPCDeath[npc.index] = view_as<Function>(OmegaRaid_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(OmegaRaid_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(OmegaRaid_ClotThink);

		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0, 100);	
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0, 100);	

		if(item)
		{
			RaidModeTime = GetGameTime(npc.index) + 240.0;
		}
		else
		{
			RaidModeTime = GetGameTime(npc.index) + 200.0;
		}
		b_thisNpcIsARaid[npc.index] = true;
		b_ThisNpcIsImmuneToNuke[npc.index] = true;
		npc.m_bWasSadAlready = false;
		npc.m_flOmegaAirbornAttack = GetGameTime(npc.index) + 7.5;

		AlreadySaidWin = false;
		
		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				LookAtTarget(client_check, npc.index);
				SetGlobalTransTarget(client_check);
				ShowGameText(client_check, "item_armor", 1, "%s", "Omega shows up");
			}
		}
		
		if(Waves_InFreeplay())
		{
			switch(GetRandomInt(0,2))
			{
				case 0:
					CPrintToChatAll("{gold}Omega{default}: Apologies for being late, got held up by this guy called {fullblue}Pablo{default}.");
				case 1:
					CPrintToChatAll("{gold}Omega{default}: Time for a friendly skirmish!");
				case 2:
					CPrintToChatAll("{gold}Omega{default}: So, you called?");
			}
		}
		else
		{
			switch(GetRandomInt(0,2))
			{
				case 0:
					CPrintToChatAll("{gold}Omega{default}: Fuck this, I don't need my weapons to dispose of you.");
				case 1:
					CPrintToChatAll("{gold}Omega{default}: We meet once again.");
				case 2:
					CPrintToChatAll("{gold}Omega{default}: A lot of dead bodies on the way here.");
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
		strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/combinehell/cauterizer.mp3");
		music.Time = 190;
		music.Volume = 2.0;
		music.Custom = false;
		strcopy(music.Name, sizeof(music.Name), "Cauterizer (+ Gravity Perforation Detail)");
		strcopy(music.Artist, sizeof(music.Artist), "Valve");
		Music_SetRaidMusic(music);

		//IDLE
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		npc.Anger = false;
		b_ThisNpcIsImmuneToNuke[npc.index] = true;
				
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		return npc;
	}
}

static void RocketBarrage_Ability(OmegaRaid npc, int target)
{
	if(npc.m_flOmegaAirbornAttack < GetGameTime(npc.index))
	{
		if(IsValidEnemy(npc.index, target))
		{
			static float flPos[3]; 
			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flPos);
			flPos[2] += 5.0;
			ParticleEffectAt(flPos, "taunt_flip_land_red", 0.25);
			npc.PlayPullSound();
			flPos[2] += 500.0;
			npc.SetVelocity({0.0,0.0,0.0});
			PluginBot_Jump(npc.index, flPos);
			AcceptEntityInput(npc.m_iWearable4, "Enable");
			//ApplyStatusEffect(npc.index, npc.index, "Solid Stance", 3.0);
			npc.m_flOmegaRPGHappening = GetGameTime(npc.index) + 1.0;
			//b_NoGravity[npc.index] = true;

			npc.AddGesture("ACT_RANGE_ATTACK_RPG");
			npc.PlayRangedSound();
			float VecEnemy[3]; WorldSpaceCenter(target, VecEnemy);
			//int MaxCount = RoundToNearest(2.0 * RaidModeScaling);
			npc.FaceTowards(VecEnemy, 99999.9);
			//float pos[3];
			//GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
			//pos[2] += 5.0;
			//float ang_Look[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang_Look);
			npc.m_flOmegaAirbornAttack = GetGameTime(npc.index) + 30.0;
			if(npc.Anger)
				ApplyStatusEffect(npc.index, npc.index, "Defensive Backup", 3.0);

			if(!IsValidEntity(npc.m_iWearable8))
			{
				float flAng[3];
				npc.GetAttachment("back_lower1", flPos, flAng);
				npc.m_iWearable8 = ParticleEffectAt_Parent(flPos, "rocketpack_exhaust", npc.index, "back_lower1", {0.0, 0.0, 0.0});
			}
		}
	}
}

static bool Omega_AirAttack(OmegaRaid npc)
{
	if(npc.m_flOmegaRPGHappening)
	{
		if(!IsValidEnemy(npc.index, npc.m_iTarget))
		{
			//bool ForceRedo = false;
			npc.m_flGetClosestTargetTime = 0.0;
			
			if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
			{
				npc.m_iTarget = GetClosestTarget(npc.index);
				npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
			}
		}
		else
		{
			npc.SetGoalEntity(npc.m_iTarget);
			if(npc.m_flAttackHappens < GetGameTime(npc.index))
			{
				int TargetEnemy = false;
				TargetEnemy = GetClosestTarget(npc.index,.ingore_client = LastEnemyTargeted[npc.index],  .CanSee = true, .UseVectorDistance = true);
				LastEnemyTargeted[npc.index] = TargetEnemy;
				if(TargetEnemy == -1)
				{
					TargetEnemy = GetClosestTarget(npc.index, .CanSee = true, .UseVectorDistance = true);
				}
				if(IsValidEnemy(npc.index, TargetEnemy))
				{
					npc.m_flAttackHappens = GetGameTime(npc.index) + 0.25;
					if(npc.Anger)
					{
						npc.m_flAttackHappens = GetGameTime(npc.index) + 0.15;
					}

					npc.AddGesture("ACT_RANGE_ATTACK_RPG",_,_,_, 2.0);
					int PrimaryThreatIndex = npc.m_iTarget;
					float DamageCalc = 30.0 * RaidModeScaling;
					float VecEnemy[3]; WorldSpaceCenter(TargetEnemy, VecEnemy);
					float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
					npc.FaceTowards(VecEnemy, 150.0);
					//NemalAirSlice(npc.index, TargetEnemy, DamageCalc, 215, 150, 0, 200.0, 6, 1750.0, "rockettrail_fire");
					npc.PlayRangedSound();
					npc.FireRocket(vecTarget, DamageCalc, 1000.0, "models/weapons/w_missile.mdl", 1.75);
				}
			}
		}
		if(npc.m_flOmegaRPGHappening < GetGameTime(npc.index))
		{
			if(npc.m_iChanged_WalkCycle != 999)
			{
				npc.m_iChanged_WalkCycle = 999;
				i_NpcWeight[npc.index] = 999;
				b_NoGravity[npc.index] = true;
				npc.m_flAttackHappens = 0.0;
				npc.SetVelocity({0.0,0.0,0.0});
				npc.m_flOmegaRPGHappening = GetGameTime(npc.index) + 2.0;	
				npc.m_bisWalking = false;
				//npc.SetActivity("ACT_MP_JUMP_FLOAT_MELEE_ALLCLASS");
				return true;
			}
			npc.m_iChanged_WalkCycle = 0;
			i_NpcWeight[npc.index] = 4;
			b_NoGravity[npc.index] = false;
			npc.i_GunMode = 0;
			npc.m_flAttackHappens = 0.0;
			npc.m_flOmegaRPGHappening = 0.0;	
			npc.SetVelocity({0.0,0.0,-1000.0});
			//npc.LookupActivity("ACT_BRAWLER_RUN");
			if(IsValidEntity(npc.m_iWearable8))
			RemoveEntity(npc.m_iWearable8);
			AcceptEntityInput(npc.m_iWearable4, "Disable");
			npc.m_bisWalking = true;
		}
		return true;
	}
	return false;
}

public void OmegaRaid_ClotThink(int iNPC)
{
	OmegaRaid npc = view_as<OmegaRaid>(iNPC);
	
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();

	if(LastMann)
	{
		if(!npc.m_fbGunout)
		{
			npc.m_fbGunout = true;
			
			if(Waves_InFreeplay())
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
					{
						CPrintToChatAll("{gold}Omega{default}: You've 'beat' me once before, come on, you can do it a second time.");
					}
					case 1:
					{
						CPrintToChatAll("{gold}Omega{default}: If you can't beat me, the fate of our world is doomed.");
					}
				}
			}
			else
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
					{
						CPrintToChatAll("{gold}Omega{default}: One shot, one kill.");
					}
					case 1:
					{
						CPrintToChatAll("{gold}Omega{default}: Hand him over and I might just let you walk out of here alive.");
					}
				}
			}
		}
	}

	if(npc.m_bWasSadAlready)
	{
		npc.StopPathing();
		if(OmegasRabiling())
		{
			npc.m_bDissapearOnDeath = true;
			RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
		}
		else
		{
			float flMaxhealth = float(ReturnEntityMaxHealth(npc.index));
			flMaxhealth *= 0.01;
			HealEntityGlobal(npc.index, npc.index, flMaxhealth, 50.0, 0.0, HEAL_SELFHEAL);
			RaidModeScaling += GetRandomFloat(5.0, 10.0);
		}
		return;
	}

	if(i_RaidGrantExtra[npc.index] == RAIDITEM_INDEX_WIN_COND)
	{
		func_NPCThink[npc.index] = INVALID_FUNCTION;
		
		CPrintToChatAll("{gold}Omega{default}: Well...now what?");
		return;
	}

	//idk it never was in a bracket
	if(IsValidEntity(RaidBossActive) && RaidModeTime < GetGameTime())
	{
		if(RaidModeTime < GetGameTime())
		{
			ForcePlayerLoss();
			RaidBossActive = INVALID_ENT_REFERENCE;
			CPrintToChatAll("{gold}Omega{default}: {default}Tempus Fugit.{default}");
			func_NPCThink[npc.index] = INVALID_FUNCTION;
			return;
		}
	}

	if(npc.m_flOmegaRPGHappening)
	{
		if(Omega_AirAttack(npc))
			return;
	}
	
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
		if(npc.m_flNextRangedSpecialAttack < GetGameTime(npc.index) && flDistanceToTarget > 62500 && flDistanceToTarget < 122500 && npc.m_flReloadDelay < GetGameTime(npc.index))
		{
			RocketBarrage_Ability(npc, closest);
			npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + 20.0;
			if(npc.Anger)
			{
				npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + 15.0;
			}
		}
		
		Omegas_SelfDefense(npc, gameTime, npc.m_iTarget, flDistanceToTarget);
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

static void Omegas_SelfDefense(OmegaRaid npc, float gameTime, int target, float flDistanceToTarget)
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
				int closest = npc.m_iTarget;
				float vecTarget[3]; WorldSpaceCenter(closest, vecTarget);
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

							npc.m_iOverlordComboAttack++;
							WorldSpaceCenter(targetTrace, vecHit);

							if(damage <= 1.0)
							{
								damage = 1.0;
							}
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
										TF2_AddCondition(targetTrace, TFCond_LostFooting, 0.5);
										TF2_AddCondition(targetTrace, TFCond_AirCurrent, 0.5);
									}
								}
								else
								{
									if(!silenced)
									{
										TF2_AddCondition(targetTrace, TFCond_LostFooting, 0.5);
										TF2_AddCondition(targetTrace, TFCond_AirCurrent, 0.5);
									}
								}
							}
							if(npc.m_iOverlordComboAttack >= 5)
							{
								float flPos[3];
								if(!IsValidEntity(npc.m_iWearable9))
								{
									float flAng[3];
									npc.GetAttachment("LHand", flPos, flAng);
									npc.m_iWearable9 = ParticleEffectAt_Parent(flPos, "unusual_electric_parent_gold", npc.index, "LHand", {0.0, 0.0, 0.0});
								}
								if(!IsValidEntity(npc.m_iWearable7))
								{
									float flAng[3];
									npc.GetAttachment("RHand", flPos, flAng);
									npc.m_iWearable7 = ParticleEffectAt_Parent(flPos, "unusual_electric_parent_gold", npc.index, "RHand", {0.0, 0.0, 0.0});
								}
							}
							if(npc.m_iOverlordComboAttack >= 10)
							{
								damage *= RaidModeScaling + 100.0;
								npc.AddGesture("ACT_PUSH_PLAYER");
								float duration = 1.0;
								if(target <= MaxClients && target > 0)
								{
								    TF2_AddCondition(target, TFCond_FreezeInput, duration);  
								}
								else
								{
								    FreezeNpcInTime(target, duration);
								}
								Custom_Knockback(npc.index, targetTrace, 1000.0, true, true);
								Explode_Logic_Custom(50.0, -1, npc.index, -1, vecTarget, 100.0, _, _, true, _, false);
								ParticleEffectAt(vecTarget, "hightower_explosion", 1.0);
								npc.PlayMeleeStunSound();
								npc.PlayBoomSound();
								//AcceptEntityInput(npc.m_iWearable4, "Enable");
								npc.m_iOverlordComboAttack = 0;
							}
							if(npc.m_iOverlordComboAttack <= 1)
							{
							
								if(IsValidEntity(npc.m_iWearable9))
								RemoveEntity(npc.m_iWearable9);
								if(IsValidEntity(npc.m_iWearable7))
								RemoveEntity(npc.m_iWearable7);
							}	
							if(!Knocked)
								Custom_Knockback(npc.index, targetTrace, 125.0, true); 
					
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

	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.25))
		{
			int Enemy_I_See;
			Enemy_I_See = Can_I_See_Enemy(npc.index, target);

			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;

				npc.PlayMeleeSound();
				switch(GetRandomInt(0,1))
				{
					case 0:
					{
						npc.AddGesture("ACT_BRAWLER_ATTACK_LEFT");
					}
					case 1:
					{
						npc.AddGesture("ACT_BRAWLER_ATTACK_RIGHT");
					}
				}
				npc.m_flAttackHappens = gameTime + 0.1;
				npc.m_flNextMeleeAttack = gameTime + 0.50;
				if(npc.Anger)
				{
					npc.m_flAttackHappens = gameTime + 0.1;
					npc.m_flNextMeleeAttack = gameTime + 0.30;
				}
				return;
			}
		}
	}
}
static Action OmegaRaid_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	OmegaRaid npc = view_as<OmegaRaid>(victim);
	
	int closest = npc.m_iTarget;
	float vecTarget[3]; WorldSpaceCenter(closest, vecTarget);
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	
	}
	if((ReturnEntityMaxHealth(npc.index)/2) >= GetEntProp(npc.index, Prop_Data, "m_iHealth") && !npc.Anger)
	{
		if(Waves_InFreeplay())
		{
			CPrintToChatAll("{gold}Omega{default}: Alright, time to quit playing around.");
		}
		else
		{
			CPrintToChatAll("{gold}Omega{default}: God damn it! Just die already!");
		}
		npc.Anger = true;
		ApplyStatusEffect(npc.index, npc.index, "Mazeat Command", 10.0);
		ParticleEffectAt(vecTarget, "hammer_bell_ring_shockwave", 1.0);
	}
	OmegaRaid_Weapon_Lines(npc, attacker);
	i_SaidLineAlready[npc.index] = 0;
	if(i_RaidGrantExtra[npc.index] == 5)
	{
		if(!npc.m_bWasSadAlready)
		{
			if(damage >= GetEntProp(npc.index, Prop_Data, "m_iHealth"))
			{
				npc.m_bWasSadAlready = true;
				npc.Anger = false;
				OmegaRaid_DefeatAnimation(npc);
			}
		}
	}
	
		
	return Plugin_Changed;
}

public void OmegaRaid_NPCDeath(int entity)
{
	OmegaRaid npc = view_as<OmegaRaid>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	if(npc.m_bDissapearOnDeath)
	{
		float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
		ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);
		npc.PlayTeleSound();
	}
	Music_SetRaidMusicSimple("vo/null.mp3", 60, false, 0.5);

	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable7))
		RemoveEntity(npc.m_iWearable7);
	if(IsValidEntity(npc.m_iWearable8))
		RemoveEntity(npc.m_iWearable8);
	if(IsValidEntity(npc.m_iWearable9))
		RemoveEntity(npc.m_iWearable9);

}

static void OmegaRaid_Weapon_Lines(OmegaRaid npc, int client)
{
	if(client > MaxClients)
		return;

	if(b_said_player_weaponline[client])	//only 1 line per player.
		return;

	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

	if(!IsValidEntity(weapon))	//invalid weapon, go back and get a valid one you <...>
		return;

	float GameTime = GetGameTime();	//no need to throttle this.

	if(fl_said_player_weaponline_time[npc.index] > GameTime)	//no spamming in chat please!
		return;

	bool valid = true;
	char Text_Lines[255];

	Text_Lines = "";

	switch(i_CustomWeaponEquipLogic[weapon])
	{
		
		case WEAPON_SENSAL_SCYTHE,WEAPON_SENSAL_SCYTHE_PAP_1,WEAPON_SENSAL_SCYTHE_PAP_2,WEAPON_SENSAL_SCYTHE_PAP_3:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "Oh God... hope you didn't have to run into {blue}him{default}.",client);
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "What, are you like a {midnightblue}Jester{default} or something?");
			}
		}
		case WEAPON_FUSION,WEAPON_FUSION_PAP1,WEAPON_FUSION_PAP2:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "{gold}Silvester?{default} hmpf, one of the few tolerable people.",client);
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "Weapons don't grow on trees, why does {gold}he{default} keep giving them away for free?");
			}
		}
		case WEAPON_KAHMLFIST:
		{
			if(Waves_InFreeplay())
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
						Format(Text_Lines, sizeof(Text_Lines), "Y'know, after learning about what happened to Messenger...maybe {darkblue}he{default} deserved it.");
					case 1:
						Format(Text_Lines, sizeof(Text_Lines), "Ugh.");
				}
			}
			else
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
						Format(Text_Lines, sizeof(Text_Lines), "{darkblue}Kahmlstein{default} huh...I don't think of him too fondly, but don't judge a book by its cover, as they say.");
					case 1:
						Format(Text_Lines, sizeof(Text_Lines), "Well, at least {darkblue}he's{default} in a better place now! Haha... ehhhh",client);
				}	
			}
		}  
		case WEAPON_KIT_BLITZKRIEG_CORE:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "How can {gold}Expidonsa{default} be so smart, yet so god damn{crimson}stupid{default} at the same time?");
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "Have {gold}they{default} never watched any movies involving rogue {crimson}AI{default}?",client);
			}
		}
		case WEAPON_RED_BLADE:
		{
			if(Waves_InFreeplay())
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
						Format(Text_Lines, sizeof(Text_Lines), "Well, someone's gotta carry on his legacy...wield that blade with respect to Guln.");
					case 1:
						Format(Text_Lines, sizeof(Text_Lines), "If I had a time machine, the first thing I would do is instantly {crimson}murder Whiteflower in cold blood, before he would get the chance to murder Guln{default}.");
				}
			}
			else
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
						Format(Text_Lines, sizeof(Text_Lines), "{crimson}Guln{default}...No...");
					case 1:
						Format(Text_Lines, sizeof(Text_Lines), "And {crimson}Guln's{default}passing is why I'm here. That {crimson}slimy judas Whiteflower{default} will pay.");
				}
			}
		}
		case WEAPON_SPIKELAYER:
		{
			if(Waves_InFreeplay())
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
						Format(Text_Lines, sizeof(Text_Lines), "Real question here, does anyone even get hurt by these?");
					case 1:
						Format(Text_Lines, sizeof(Text_Lines), "Whoever made these knock-off Legos is gonna get sued.");
				}
			}
			else
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
						Format(Text_Lines, sizeof(Text_Lines), "Haven't had a foot massage in a while, thank you {gold}%N{default}.");
					case 1:
						Format(Text_Lines, sizeof(Text_Lines), "You ever tried Firewalking? This is nothing to me.");
				}
			}
		}
		case WEAPON_BOARD:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "{gold}%N{default}, this is the equivalent of bringing a sword to a gun fight.",client);
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "The hell's a shield gonna do?");
			}
		}
		case WEAPON_BOBS_GUN:  Format(Text_Lines, sizeof(Text_Lines), "YOU CHEATING SON OF A BITCH!");
		case WEAPON_HHH_AXE:  Format(Text_Lines, sizeof(Text_Lines), "I've seen {darkblue}Abominations{default} before, but you're something else, {gold}%N{default}.",client);
		case WEAPON_MLYNAR_PAP_2,WEAPON_MLYNAR_PAP,WEAPON_MLYNAR:
		{
			if(Waves_InFreeplay())
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
						Format(Text_Lines, sizeof(Text_Lines), "What's the point of that newspaper? You're just standing there, not realizing what's happening.");
					case 1:
						Format(Text_Lines, sizeof(Text_Lines), "Come to think of it...who the hell is producing these newspapers?");
				}
			}
			else
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
						Format(Text_Lines, sizeof(Text_Lines), "My eye is up here, {gold}%N{default}.",client);	
					case 1:
						Format(Text_Lines, sizeof(Text_Lines), "So you take {white}Bob{default} hostage and then pretend to be reading the news {gold}%N{default}?",client);
				}
			}
		}
		case WEAPON_MESSENGER_LAUNCHER:
		{
			if(Waves_InFreeplay())
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
						Format(Text_Lines, sizeof(Text_Lines), "{white}Bob{default} told me about Messenger...I am not. happy.");
					case 1:
						Format(Text_Lines, sizeof(Text_Lines), "If there's an afterlife, I'm sure Messenger didn't go to hell, he was just... naive, what a poor guy.");
				}
			}
			else
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
						Format(Text_Lines, sizeof(Text_Lines), "Heyyy, {blue}Messenger{default} gave you that? I knew he had good intentions at heart.");
					case 1:
						Format(Text_Lines, sizeof(Text_Lines), "I miss {blue}Messenger{default}. I wonder what he's up to, haven't seen him in a while.",client);
				}	
			}
		}
		case WEAPON_FLAMETAIL:
		{
			if(Waves_InFreeplay())
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
						Format(Text_Lines, sizeof(Text_Lines), "Gahahaha, sorry, I just remembered what they used to call that weapon...God how immature of me.");
					case 1:
						Format(Text_Lines, sizeof(Text_Lines), "That's an alright weapon, wouldn't be my first pick though.");
				}
			}
			else
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
						Format(Text_Lines, sizeof(Text_Lines), "Dodge this.");
					case 1:
						Format(Text_Lines, sizeof(Text_Lines), "You'll probably make better use of that 'weapon' as a torch, {gold}%N{default}.",client);
				}
			}
		}
		case WEAPON_LEPER_MELEE, WEAPON_LEPER_MELEE_PAP:
		{
			if(Waves_InFreeplay())
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
						Format(Text_Lines, sizeof(Text_Lines), "You've gotten better at your poses since our last fight, {gold}%N{default}.",client);
					case 1:
						Format(Text_Lines, sizeof(Text_Lines), "So...have you tried tinkering about with that thing to swing faster?");
				}
			}
			else
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
						Format(Text_Lines, sizeof(Text_Lines), "I'm surprised your skinny arms are able to hold that thing, {gold}%N{default}.",client);
					case 1:
						Format(Text_Lines, sizeof(Text_Lines), "And pose for the fans {gold}%N{default}! Oh wait, you don't have any.",client);
				}
			}
		}
		case WEAPON_SKULL_SERVANT:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "Ehhh, I'm not worried if {green}he{default} makes a return, I'd pay to watch the shitshow.",client);
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "Y'know what? I HOPE {green}he{default} comes back.",client);
			}
		}
		case WEAPON_SEABORN_MISC:
		{
			if(Waves_InFreeplay())
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
						Format(Text_Lines, sizeof(Text_Lines), "How the hell are you able to harness its power?");
					case 1:
						Format(Text_Lines, sizeof(Text_Lines), "Well after everything you've went through, it shouldn't surprise me that the Seaborn infection doesn't affect you, {gold}%N{default}.",client);
				}
			}
			else
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
						Format(Text_Lines, sizeof(Text_Lines), "{white}Bob's{default} dealt with your kind before.");
					case 1:
						Format(Text_Lines, sizeof(Text_Lines), "{white}Bob{default} I know you're being held hostage, but you might specifically want to stay away from {gold}%N{default}.",client);
				}
			}
		}
		case WEAPON_BOOMSTICK:
		{
			if(Waves_InFreeplay())
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
						Format(Text_Lines, sizeof(Text_Lines), "The Boomstick used to be my go-to weapon. Switched out for my trusty RPG though.");
					case 1:
						Format(Text_Lines, sizeof(Text_Lines), "You do look pretty badass when you're holding that thing, {gold}%N{default}.",client);
				}
			}
			else
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
						Format(Text_Lines, sizeof(Text_Lines), "Ahhh, good ol' boomstick...is what I would say if I was a COWARD, HIT ME LIKE A MAN!");
					case 1:
						Format(Text_Lines, sizeof(Text_Lines), "Yeah use that knockback of yours, {gold}%N{default}, I'm sure that'll benefit your team.",client);
				}
			}
		}
		case WEAPON_FIRE_WAND:
		{
			if(Waves_InFreeplay())
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
						Format(Text_Lines, sizeof(Text_Lines), "Caveman's magic eh? Pff, I'm just joking around.");
					case 1:
						Format(Text_Lines, sizeof(Text_Lines), "ent_fire !picker ignite. Whoa. What the hell was that. Felt like something possessed me there for a second.");
				}
			}
			else
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
						Format(Text_Lines, sizeof(Text_Lines), "OH GOD IT BURNS! Nope, forgot that I'm basically fire retardant.");
					case 1:
						Format(Text_Lines, sizeof(Text_Lines), "Trust me, that little speck of fire would do a lot more to me if I still had any working pain receptors.",client);
				}
			}
		}
		case WEAPON_CASINO:
		{
			if(Waves_InFreeplay())
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
						Format(Text_Lines, sizeof(Text_Lines), "Heard of this guy called {fullblue}Gambler{default}? I figured I'd ask since he's looking for gambling addicts to play Blackjack with.");
					case 1:
						Format(Text_Lines, sizeof(Text_Lines), "Saw this {fullblue}guy{default} walk into {navy}Bladedance's{default} casino one time...his luck was immeasurable, and he turned out to be pretty cool too.",client);
				}
			}
			else
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
						Format(Text_Lines, sizeof(Text_Lines), "Have you seen {navy}Bladedance{default} anywhere? That guy owes me.");
					case 1:
						Format(Text_Lines, sizeof(Text_Lines), "Oh {gold}%N{default}, you poor soul, I'll put you out of your addiction.",client);
				}
			}
		}
		case WEAPON_DIMENSION_RIPPER:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "Is this some kind of sick joke?");
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "Where in the fuck did you get that, {gold}%N{default}.",client);
			}
		}
		case WEAPON_MAGNESIS:
		{
			if(Waves_InFreeplay())
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
						Format(Text_Lines, sizeof(Text_Lines), "This is exactly what I mean. Magic is utter nonsense.");
					case 1:
						Format(Text_Lines, sizeof(Text_Lines), "I think I played a videogame before that allowed you to do the exact same thing, {gold}%N{default}. Forgot the name of it though.");
				}
			}
			else
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
						Format(Text_Lines, sizeof(Text_Lines), "Make sure to not get overwhelmed by holding me for more than 2 seconds.");
					case 1:
						Format(Text_Lines, sizeof(Text_Lines), "The moment you let go of me, I will choke you out, {gold}%N{default}. With my own hands.",client);
				}
			}
		}
		case WEAPON_WRATHFUL_BLADE:
		{
			if(Waves_InFreeplay())
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
						Format(Text_Lines, sizeof(Text_Lines), "How do you even spontaneously combust like that?");
					case 1:
						Format(Text_Lines, sizeof(Text_Lines), "That can't be good for your health, {gold}%N{default}.",client);
				}
			}
			else
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
						Format(Text_Lines, sizeof(Text_Lines), "I've had scarier encounters with the paranormal.");
					case 1:
						Format(Text_Lines, sizeof(Text_Lines), "Ahhh! You *really* scared me with that roar of yours, {gold}%N{default}.",client);
				}
			}
		}
		case WEAPON_CHAINSAW:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "I had this nightmare once where I-...eh, forget it.");
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "Hope you're efficient with your fuel, {gold}%N{default}.",client);
			}
		}
		case WEAPON_MG42:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "How fast does that thing shoot again?");
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "Solid weapon choice, {gold}%N{default}. I respect it.",client);
			}
		}
		case WEAPON_GRAVATON_WAND:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "You have no concept of how much I hate magic.");
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "{gold}Ruianians{default} gave you this weapon {gold}%N{default}? Can't say I'm surprised.",client);
			}
		}
		case WEAPON_NECRO_WANDS:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "And here I thought magic couldn't get any more ridiculous. I stand corrected.");
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "Get your anklebiter off of me before I kick it, {gold}%N{default}.",client);
			}
		}
		case WEAPON_SPEEDFISTS:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "A worthy opponent. At last.");
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "Hand to hand combat. You have my respect, {gold}%N{default}.",client);
			}
		}

		default:
		{
			valid = false;
		}
	}

	if(valid)
	{
		CPrintToChatAll("{gold}Omega{default}: %s", Text_Lines);
		fl_said_player_weaponline_time[npc.index] = GameTime + GetRandomFloat(15.0, 22.0);
		b_said_player_weaponline[client] = true;
	}
}

static void OmegaRaid_GrantItem()
{
	for (int client = 1; client <= MaxClients; client++)
	{
		if(IsValidClient(client) && GetClientTeam(client) == 2 && TeutonType[client] != TEUTON_WAITING && PlayerPoints[client] > 500)
		{
			Items_GiveNamedItem(client, "Omega's Medallion");
			CPrintToChat(client,"{white}Bob{default} convinced {gold}Omega{default} that he was being protected by you, by holding off {crimson}Whiteflower's{default} army, in return, you got {gold}Omega's Medallion{default}!");
		}
	}
}

void OmegaRaid_DefeatAnimation(OmegaRaid npc)
{
	//rapid self heal to indicate power!
	npc.m_bisWalking = false;
	npc.AddActivityViaSequence("idle_NPC_impatient");
	int iActivity = npc.LookupActivity("ACT_IDLE_IMPATIENT");
	if(iActivity > 0) npc.StartActivity(iActivity);
	npc.SetActivity("ACT_IDLE_IMPATIENT");
	npc.StopPathing();
	
	npc.m_flSpeed = 0.0;
	//npc.SetCycle(0.50);//why
	//npc.SetPlaybackRate(1.0);	
	npc.ArmorSet(_, true);
	b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true; //Make allied npcs ignore him.
	b_DoNotUnStuck[npc.index] = true;
	b_CantCollidieAlly[npc.index] = true;
	b_CantCollidie[npc.index] = true;
	GiveProgressDelay(28.0);
		
}

static void OmegaRaid_Reply(char text[255])
{
	CPrintToChatAll("{gold}Omega{default}: %s", text);
}

static bool OmegasRabiling()
{
	int maxyapping = 13;
	if(i_TalkDelayCheck == maxyapping)
	{
		return true;
	}
	if(f_TalkDelayCheck < GetGameTime())
	{
		f_TalkDelayCheck = GetGameTime() + 4.0;
		RaidModeTime += 10.0; //cant afford to delete it, since duo.
		i_TalkDelayCheck++;
		switch(i_TalkDelayCheck)
		{
			case 0:
			{
				ReviveAll(true);
				OmegaRaid_Reply("{default}Alright, that's enough of playing around, let's get this done.");
			}
			case 1:
			{
				CPrintToChatAll("{white}Bob{default}: I don't think that'll be necessary, Omega");
			}
			case 2:
			{
				OmegaRaid_Reply("{default}Huh?");
			}
			case 3:
			{
				CPrintToChatAll("{white}Bob{default}: You do realize that I'm not actually in any type of danger, right?");
			}
			case 4:
			{
				OmegaRaid_Reply("{default}But {crimson}Whiteflower{default} sent his army to finish you for good!");
			}
			case 5:
			{
				CPrintToChatAll("{white}Bob{default}: Well, the pile of corpses speaks for itself.");
			}
			case 6:
			{
				OmegaRaid_Reply("{default}So you're saying that all this fighting was for nothing?");
			}
			case 7:
			{
				CPrintToChatAll("{white}Bob{default}: Pretty much so.");
			}
			case 8:
			{
				OmegaRaid_Reply("{default}Damn...well, at least I'm keeping myself in check, can't become too weak.");
			}
			case 9:
			{
				OmegaRaid_Reply("{default}Why didn't you just tell me that you weren't in any danger right off the bat?");
			}
			case 10:
			{
				CPrintToChatAll("{white}Bob{default}: I wanted to see how far in depth you would go to save me. Friendship test.");
			}
			case 11:
			{
				OmegaRaid_Reply("{default}Oh please, you know I would never leave you hanging.");
			}
			case 12:
			{
				OmegaRaid_Reply("{default}Well, I suppose an apology is owed for attacking you, mercenaries.");
			}
			case 13:
			{
				OmegaRaid_Reply("{default}Here, take this. Bob...let's get out of here.");
				i_TalkDelayCheck = maxyapping;
				OmegaRaid_GrantItem();
			}
		}
	}
	return false;
}

public void RaidMode_OmegaRaid_WinCondition(int entity)
{
	i_RaidGrantExtra[entity] = RAIDITEM_INDEX_WIN_COND;
	func_NPCThink[entity] = INVALID_FUNCTION;
	if(AlreadySaidWin)
		return;

	AlreadySaidWin = true;
	if(Waves_InFreeplay())
	{
		switch(GetRandomInt(0,2))
		{
			case 0:
			{
				OmegaRaid_Reply("{default}Aw come on, I was rootin' for you.");
			}
			case 1:
			{
				OmegaRaid_Reply("{default}I'm sorry for saying this but...you've gone soft, you need to get stronger to be able to defeat {purple}it{default}.");
			}
			case 2:
			{
				OmegaRaid_Reply("{default}You can't lose! The fate of this world is in your hands, god damn it!");
			}
		}
	}
	else
	{
		switch(GetRandomInt(0, 6))
		{
			case 0:
			{
				OmegaRaid_Reply("{default}Well {white}Bob{default}, I saved you once again, no need to thank me.");
			}
			case 1:
			{
				OmegaRaid_Reply("{default}Wanna grab some beer after this, {white}Bob{default}?");
			}
			case 2:
			{
				OmegaRaid_Reply("{default}Survival of the fittest.");
			}
			case 3:
			{
				OmegaRaid_Reply("{default}You gotta do what you gotta do to survive.");
			}
			case 4:
			{
				OmegaRaid_Reply("{default}You shouldn't have kept him captive.");
			}
			case 5:
			{
				OmegaRaid_Reply("{crimson}Whiteflower {default}must've cut his budget huh?");
			}
			case 6:
			{
				OmegaRaid_Reply("{default}Well, that wasn't nearly as difficult as I was expecting it to be.");
			}
		}
	}
}
