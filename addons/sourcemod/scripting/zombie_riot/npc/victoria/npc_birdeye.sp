#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/sniper_negativevocalization01.mp3",
	"vo/sniper_negativevocalization02.mp3",
	"vo/sniper_negativevocalization03.mp3",
	"vo/sniper_negativevocalization04.mp3",
	"vo/sniper_negativevocalization05.mp3",
	"vo/sniper_negativevocalization06.mp3",
	"vo/sniper_negativevocalization07.mp3",
	"vo/sniper_negativevocalization08.mp3",
	"vo/sniper_negativevocalization09.mp3"
};

static const char g_HurtSounds[][] = {
	"vo/sniper_painsharp01.mp3",
	"vo/sniper_painsharp02.mp3",
	"vo/sniper_painsharp03.mp3",
	"vo/sniper_painsharp04.mp3"
};

static const char g_IdleAlertedSounds[][] = {
	"vo/sniper_specialcompleted01.mp3",
	"vo/sniper_specialcompleted02.mp3",
	"vo/sniper_specialcompleted03.mp3",
	"vo/sniper_specialcompleted04.mp3",
	"vo/sniper_specialcompleted05.mp3",
	"vo/sniper_specialcompleted06.mp3",
	"vo/sniper_specialcompleted07.mp3",
	"vo/sniper_specialcompleted08.mp3",
	"vo/sniper_specialcompleted09.mp3",
	"vo/sniper_specialcompleted10.mp3",
	"vo/sniper_specialcompleted11.mp3",
	"vo/sniper_specialcompleted12.mp3",
	"vo/sniper_specialcompleted13.mp3",
	"vo/sniper_specialcompleted14.mp3",
	"vo/sniper_specialcompleted15.mp3",
	"vo/sniper_specialcompleted16.mp3",
	"vo/sniper_specialcompleted17.mp3",
	"vo/sniper_specialcompleted18.mp3",
	"vo/sniper_specialcompleted19.mp3",
	"vo/sniper_specialcompleted20.mp3",
	"vo/sniper_specialcompleted21.mp3",
	"vo/sniper_specialcompleted22.mp3",
	"vo/sniper_specialcompleted23.mp3",
	"vo/sniper_specialcompleted24.mp3",
	"vo/sniper_specialcompleted25.mp3",
	"vo/sniper_specialcompleted26.mp3",
	"vo/sniper_specialcompleted27.mp3",
	"vo/sniper_specialcompleted28.mp3",
	"vo/sniper_specialcompleted29.mp3",
	"vo/sniper_specialcompleted30.mp3",
	"vo/sniper_specialcompleted31.mp3",
	"vo/sniper_specialcompleted32.mp3",
	"vo/sniper_specialcompleted33.mp3",
	"vo/sniper_specialcompleted34.mp3",
	"vo/sniper_specialcompleted35.mp3",
	"vo/sniper_specialcompleted36.mp3",
	"vo/sniper_specialcompleted37.mp3",
	"vo/sniper_specialcompleted38.mp3",
	"vo/sniper_specialcompleted39.mp3",
	"vo/sniper_specialcompleted40.mp3",
	"vo/sniper_specialcompleted41.mp3",
	"vo/sniper_specialcompleted42.mp3",
	"vo/sniper_specialcompleted43.mp3",
	"vo/sniper_specialcompleted44.mp3",
	"vo/sniper_specialcompleted45.mp3",
	"vo/sniper_specialcompleted46.mp3"
};

static const char g_TeleportSounds[][] = {
	"weapons/rescue_ranger_teleport_receive_01.wav",
	"weapons/rescue_ranger_teleport_receive_02.wav"
};

static const char g_RangeAttackSounds[] = "weapons/csgo_awp_shoot_crit.wav";

static const char g_ReloadSound[] = "weapons/ar2/npc_ar2_reload.wav";

static bool b_GotBuilding[MAXENTITIES];
static int i_AttackCount[MAXENTITIES];

static bool b_TheGoons;

void VictoriaBirdeye_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Birdeye");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_birdeye");
	strcopy(data.Icon, sizeof(data.Icon), "sniper_headshot");
	data.IconCustom = false;
	data.Flags = 0;
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
	PrecacheSoundArray(g_TeleportSounds);
	PrecacheSound(g_RangeAttackSounds);
	PrecacheSound(g_ReloadSound);
	/*PrecacheSound("weapons/sniper_railgun_bolt_forward.wav");
	PrecacheSound("weapons/smg_clip_in.wav");
	PrecacheSound("weapons/smg_clip_out.wav");*/
	PrecacheModel("models/player/sniper.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return VictoriaBirdeye(vecPos, vecAng, ally, data);
}

methodmap VictoriaBirdeye < CClotBody
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
		EmitSoundToAll(g_RangeAttackSounds, this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayRAGEattackSound()
	{
		EmitSoundToAll(g_RangeAttackSounds, this.index, SNDCHAN_AUTO, 70, _, 0.6);
	}
	public void PlayReloadSound() 
	{
		EmitSoundToAll(g_ReloadSound, this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayTeleportSound()
	{
		EmitSoundToAll(g_TeleportSounds[GetRandomInt(0, sizeof(g_TeleportSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}

	property int m_iBigPipe
	{
		public get()							{ return i_AmountProjectiles[this.index]; }
		public set(int TempValueForProperty) 	{ i_AmountProjectiles[this.index] = TempValueForProperty; }
	}
	property int m_iHarbringer
	{
		public get()							{ return this.m_iState; }
		public set(int TempValueForProperty) 	{ this.m_iState = TempValueForProperty; }
	}
	property float m_flDelaySounds
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	/*property int m_iCountSounds
	{
		public get()							{ return i_MedkitAnnoyance[this.index]; }
		public set(int TempValueForProperty) 	{ i_MedkitAnnoyance[this.index] = TempValueForProperty; }
	}*/
	property int m_iBurst
	{
		public get()							{ return i_AttacksTillMegahit[this.index]; }
		public set(int TempValueForProperty) 	{ i_AttacksTillMegahit[this.index] = TempValueForProperty; }
	}
	property int m_iAttackCount
	{
		public get()							{ return i_AttackCount[this.index]; }
		public set(int TempValueForProperty) 	{ i_AttackCount[this.index] = TempValueForProperty; }
	}
	
	public VictoriaBirdeye(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		VictoriaBirdeye npc = view_as<VictoriaBirdeye>(CClotBody(vecPos, vecAng, "models/player/sniper.mdl", "1.0", "150000", ally));
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_PRIMARY");
		if(iActivity > 0) npc.StartActivity(iActivity);

		SetVariantInt(2);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		func_NPCDeath[npc.index] = VictoriaBirdeye_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = VictoriaBirdeye_OnTakeDamage;
		func_NPCThink[npc.index] = VictoriaBirdeye_ClotThink;
		
		npc.m_iChanged_WalkCycle = 0;
		npc.g_TimesSummoned = 0;

		if(npc.m_iChanged_WalkCycle != 1)
		{
			npc.m_bisWalking = true;
			npc.m_iChanged_WalkCycle = 1;
			npc.SetActivity("ACT_MP_RUN_PRIMARY");
			npc.StartPathing();
			npc.m_flSpeed = 200.0;
		}	
		npc.m_flNextMeleeAttack = GetGameTime() + 1.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		f_HeadshotDamageMultiNpc[npc.index] = 1.25;
			
		b_ThisNpcIsImmuneToNuke[npc.index] = true;
		GiveNpcOutLineLastOrBoss(npc.index, true);
		
		//IDLE
		npc.m_flGetClosestTargetTime = 0.0;
		npc.Anger = false;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flDelaySounds = 0.0;
		npc.m_flAttackHappens = 0.0;
		//npc.m_iCountSounds = 0;
		npc.m_iBurst = 0;
		npc.m_iAttackCount = 0;
		npc.m_iAmmo = 31;
		npc.m_iMaxAmmo = 31;
		npc.m_iBigPipe=-2;
		npc.m_iHarbringer=-2;
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_pro_rifle/c_pro_rifle.mdl");
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/all_class/cc_summer2015_the_rotation_sensation_style2/cc_summer2015_the_rotation_sensation_style2_sniper.mdl");
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/sniper/spr17_down_under_duster/spr17_down_under_duster.mdl");
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/all_class/hwn2020_gourd_grin/hwn2020_gourd_grin_sniper.mdl");
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/sniper/sum23_preventative_measure/sum23_preventative_measure.mdl");

		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 1);
		SetVariantString("1.3");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);
		SetEntityRenderColor(npc.m_iWearable2, 0, 0, 0, 255);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", 1);
		SetEntityRenderColor(npc.m_iWearable4, 0, 0, 0, 255);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", 1);

		if(ally != TFTeam_Red)
		{
			if(LastSpawnDiversio < GetGameTime())
			{
				EmitSoundToAll("weapons/ar2/npc_ar2_reload.wav", _, _, _, _, 1.0);
				EmitSoundToAll("weapons/ar2/npc_ar2_reload.wav", _, _, _, _, 1.0);
				npc.m_flDelaySounds=GetGameTime()+1.0;
			}
			LastSpawnDiversio = GetGameTime() + 1.0;
			TeleportDiversioToRandLocation(npc.index, _,1750.0, 1250.0);
			float Vec[3];
			GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", Vec);
			ParticleEffectAt(Vec, "teleported_blue", 0.5);
		}
		
		b_TheGoons=false;
		if(!StrContains(data, "only"))
		{
			//The NPC name will be displayed normally only after 1 frame.
			switch(GetRandomInt(0, 4))
			{
				case 0:NPCPritToChat(npc.index, "{tan}", "birdeye_Talk_01-1", false, true);
				case 1:NPCPritToChat(npc.index, "{tan}", "birdeye_Talk_01-2", false, true);
				case 2:NPCPritToChat(npc.index, "{tan}", "birdeye_Talk_01-3", false, true);
				case 3:NPCPritToChat(npc.index, "{tan}", "birdeye_Talk_01-4", false, true);
				case 4:NPCPritToChat(npc.index, "{tan}", "birdeye_Talk_01-5", false, true);
			}
		}
		else if(!StrContains(data, "the_goons"))
		{
			b_TheGoons=true;
			npc.m_flMeleeArmor -= 0.25;
			switch(GetRandomInt(0, 2))
			{
				case 0:NPCPritToChat(npc.index, "{tan}", "birdeye_Talk_08-1", false, true);
				case 1:NPCPritToChat_Override("Bigpipe", "{forestgreen}", "bigpipe_Talk_06-1", false);
				case 2:NPCPritToChat_Override("Harbringer", "{sienna}", "harbringer_Talk_07-1", false);
			}
			RequestFrame(VictoriaBirdeye_SpawnAllyDuo, EntIndexToEntRef(npc.index));
		}
		else
		{
			switch(GetRandomInt(0, 13))
			{
				case 0:NPCPritToChat(npc.index, "{tan}", "birdeye_Talk_01-1", false, true);
				case 1:NPCPritToChat(npc.index, "{tan}", "birdeye_Talk_01-2", false, true);
				case 2:NPCPritToChat(npc.index, "{tan}", "birdeye_Talk_01-3", false, true);
				case 3:NPCPritToChat(npc.index, "{tan}", "birdeye_Talk_01-4", false, true);
				case 4:NPCPritToChat(npc.index, "{tan}", "birdeye_Talk_01-5", false, true);
				
				case 5:NPCPritToChat_Override("Bigpipe", "{forestgreen}", "bigpipe_Talk_01-1", false);
				case 6:NPCPritToChat_Override("Bigpipe", "{forestgreen}", "bigpipe_Talk_01-2", false);
				case 7:NPCPritToChat_Override("Bigpipe", "{forestgreen}", "bigpipe_Talk_01-3", false);
				case 8:NPCPritToChat_Override("Bigpipe", "{forestgreen}", "bigpipe_Talk_01-4", false);
				case 9:NPCPritToChat_Override("Bigpipe", "{forestgreen}", "bigpipe_Talk_01-5", false);
				
				case 10:NPCPritToChat_Override("Harbringer", "{sienna}", "harbringer_Talk_01-1", false);
				case 11:NPCPritToChat_Override("Harbringer", "{sienna}", "harbringer_Talk_01-2", false);
				case 12:NPCPritToChat_Override("Harbringer", "{sienna}", "harbringer_Talk_01-3", false);
				case 13:NPCPritToChat_Override("Harbringer", "{sienna}", "harbringer_Talk_01-4", false);
			}
			RequestFrame(VictoriaBirdeye_SpawnAllyDuo, EntIndexToEntRef(npc.index));
		}
		return npc;
	}
}

static void VictoriaBirdeye_ClotThink(int iNPC)
{
	VictoriaBirdeye npc = view_as<VictoriaBirdeye>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(npc.m_bAllowBackWalking)
	{
		if(IsValidEnemy(npc.index, npc.m_iTargetWalkTo))
		{
			float WorldSpaceVec[3]; WorldSpaceCenter(npc.m_iTargetWalkTo, WorldSpaceVec);
			npc.FaceTowards(WorldSpaceVec, 150.0);
		}
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
	
	if(npc.m_flDelaySounds&&npc.m_flDelaySounds<GetGameTime(npc.index))
	{
		EmitSoundToAll("weapons/sniper_railgun_world_reload.wav", _, SNDCHAN_AUTO, 90, _, 1.0);
		EmitSoundToAll("weapons/sniper_railgun_world_reload.wav", _, SNDCHAN_AUTO, 90, _, 1.0);
		npc.m_flDelaySounds=0.0;
		/*switch(npc.m_iCountSounds)
		{
			case 0:
			{
				EmitSoundToAll("weapons/syringegun_reload_air2.wav", _, SNDCHAN_AUTO, 90, _, 1.0);
				EmitSoundToAll("weapons/syringegun_reload_air2.wav", _, SNDCHAN_AUTO, 90, _, 1.0);
				npc.m_flDelaySounds=GetGameTime(npc.index)+0.01;
				npc.m_iCountSounds++;
			}
			case 1:
			{
				EmitSoundToAll("weapons/syringegun_reload_air1.wav", _, SNDCHAN_AUTO, 90, _, 1.0);
				EmitSoundToAll("weapons/syringegun_reload_air1.wav", _, SNDCHAN_AUTO, 90, _, 1.0);
				npc.m_flDelaySounds=GetGameTime(npc.index)+0.2;
				npc.m_iCountSounds++;
			}
			case 2:
			{
				EmitSoundToAll("weapons/smg_clip_out.wav", _, SNDCHAN_AUTO, 90, _, 1.0);
				EmitSoundToAll("weapons/smg_clip_out.wav", _, SNDCHAN_AUTO, 90, _, 1.0);
				npc.m_flDelaySounds=GetGameTime(npc.index)+0.3;
				npc.m_iCountSounds++;
			}
			case 3:
			{
				EmitSoundToAll("weapons/smg_clip_in.wav", _, SNDCHAN_AUTO, 90, _, 1.0);
				EmitSoundToAll("weapons/smg_clip_in.wav", _, SNDCHAN_AUTO, 90, _, 1.0);
				npc.m_flDelaySounds=GetGameTime(npc.index)+0.4;
				npc.m_iCountSounds++;
			}
			default:
			{
				EmitSoundToAll("weapons/sniper_railgun_world_reload.wav", _, SNDCHAN_AUTO, 90, _, 1.0);
				EmitSoundToAll("weapons/sniper_railgun_world_reload.wav", _, SNDCHAN_AUTO, 90, _, 1.0);
				npc.m_flDelaySounds=0.0;
			}
		}*/
	}
	
	if(npc.m_iBigPipe==-2&&npc.m_iHarbringer==-2)
	{
	}
	else
	{
		bool DeathSliding=true;
		if(!IsEntityAlive(npc.m_iBigPipe))
		{
			if(npc.m_iBigPipe!=-1)
			{
				switch(GetRandomInt(0, 1))
				{
					case 0:NPCPritToChat(npc.index, "{tan}", "birdeye_Talk_02-1", false, false);
					case 1:NPCPritToChat(npc.index, "{tan}", "birdeye_Talk_02-2", false, false);
				}
				npc.m_iBigPipe=-1;
			}
		}
		else DeathSliding=false;
		
		if(!IsEntityAlive(npc.m_iHarbringer))
		{
			if(npc.m_iHarbringer!=-1)
			{
				switch(GetRandomInt(0, 1))
				{
					case 0:NPCPritToChat(npc.index, "{tan}", "birdeye_Talk_03-1", false, false);
					case 1:NPCPritToChat(npc.index, "{tan}", "birdeye_Talk_03-2", false, false);
				}
				npc.m_iHarbringer=-1;
			}
		}
		else DeathSliding=false;
		
		if(DeathSliding&&!npc.m_bFUCKYOU)
		{
			npc.m_flNextIdleSound=0.0;
			npc.m_flAttackHappens=0.0;
			npc.PlayIdleAlertSound();
			npc.m_flMeleeArmor -= 0.3;
			npc.m_flRangedArmor -= 0.3;
			switch(GetRandomInt(0, 2))
			{
				case 0:NPCPritToChat(npc.index, "{tan}", "birdeye_Talk_04-1", false, false);
				case 1:NPCPritToChat(npc.index, "{tan}", "birdeye_Talk_04-2", false, false);
				case 2:NPCPritToChat(npc.index, "{tan}", "birdeye_Talk_04-3", false, false);
			}
			ApplyStatusEffect(npc.index, npc.index, "Ammo_TM Visualization", 999.0);
			npc.m_bFUCKYOU=true;
		}
	}

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTargetWalkTo = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTargetWalkTo))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTargetWalkTo, vecTarget);
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		int ExtraBehavior;
		if(flDistanceToTarget<NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED*14.8)
		{
			npc.m_flAttackHappens = 0.0;
			npc.m_flNextRangedAttack = GetGameTime(npc.index) + 1.0;
		}
		if(npc.m_bFUCKYOU||!npc.m_bFUCKYOU&&(Can_I_See_Enemy_Only(npc.index, npc.m_iTargetWalkTo)&&npc.m_flNextRangedAttack>GetGameTime(npc.index)))
		{
			ExtraBehavior = VictoriaBirdeyeAssaultMode(npc,GetGameTime(npc.index), npc.m_iTargetWalkTo, flDistanceToTarget); 
		}
		else
		{
			ExtraBehavior = VictoriaBirdeyeSniperMode(npc,GetGameTime(npc.index));
			if(npc.m_iAttacksTillReload!=1)
			{
				KillFeed_SetKillIcon(npc.index, "headshot");
				npc.m_iAttacksTillReload=1;
			}
		}
		switch(ExtraBehavior)
		{
			case 0:
			{
				npc.m_iBurst=0;
				if(npc.m_iChanged_WalkCycle != 1)
				{
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 1;
					npc.SetActivity("ACT_MP_RUN_PRIMARY");
					npc.StartPathing();
					npc.m_flSpeed = 200.0;
				}
			}
			case 1:
			{
				if(npc.m_iChanged_WalkCycle != 2)
				{
					npc.m_bisWalking = false;
					npc.m_iChanged_WalkCycle = 2;
					npc.SetActivity("ACT_MP_DEPLOYED_PRIMARY");
					npc.StopPathing();
					npc.m_flSpeed = 0.0;
				}
			}
			case 2:
			{
				npc.m_iBurst=0;
				if(npc.m_iChanged_WalkCycle != 1)
				{
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 1;
					npc.SetActivity("ACT_MP_RUN_PRIMARY");
					npc.StartPathing();
				}
				npc.m_flSpeed = (npc.m_flCharge_delay < GetGameTime(npc.index)) ? 280.0 : 150.0;
				npc.m_bAllowBackWalking = false;
				//Get the normal prediction code.
				if(flDistanceToTarget < npc.GetLeadRadius()) 
				{
					float vPredictedPos[3];
					PredictSubjectPosition(npc, npc.m_iTargetWalkTo,_,_, vPredictedPos);
					npc.SetGoalVector(vPredictedPos);
				}
				else 
				{
					npc.SetGoalEntity(npc.m_iTargetWalkTo);
				}
			}
			case 3:
			{
				npc.m_iBurst=0;
				if(npc.m_iChanged_WalkCycle != 1)
				{
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 1;
					npc.SetActivity("ACT_MP_RUN_PRIMARY");
					npc.StartPathing();
				}
				npc.m_flSpeed = (npc.m_flCharge_delay < GetGameTime(npc.index)) ? 280.0 : 150.0;
				npc.m_bAllowBackWalking = true;
				float vBackoffPos[3];
				BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTargetWalkTo,_,vBackoffPos);
				npc.SetGoalVector(vBackoffPos, true); //update more often, we need it
			}
			case 4:
			{
				npc.m_iBurst=0;
				if(npc.m_iChanged_WalkCycle != 2)
				{
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 2;
					npc.StartPathing();
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 2.5;
					npc.SetActivity("ACT_MP_RUN_PRIMARY");
					npc.AddGesture("ACT_MP_RELOAD_STAND_SECONDARY", true,_,_,0.37);
					npc.m_flSpeed = 350.0;
					npc.PlayReloadSound();
					npc.m_flAttackHappens = GetGameTime(npc.index) + 2.5;
				}
				if(GetGameTime(npc.index) > npc.m_flAttackHappens)
					npc.m_iAmmo=31;
				npc.m_bAllowBackWalking = true;
				float vBackoffPos[3];
				BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTargetWalkTo,_,vBackoffPos);
				npc.SetGoalVector(vBackoffPos, true);
			}
			case 5:
			{
				npc.m_iBurst=0;
				if(npc.m_iChanged_WalkCycle != 1)
				{
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 1;
					npc.SetActivity("ACT_MP_RUN_PRIMARY");
					npc.StartPathing();
				}
				npc.m_flSpeed = 280.0;
				npc.m_bAllowBackWalking = true;
				float vBackoffPos[3];
				BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTargetWalkTo,_,vBackoffPos);
				npc.SetGoalVector(vBackoffPos, true); //update more often, we need it
			}
			case 6:
			{
				if(npc.m_iChanged_WalkCycle != 3)
				{
					npc.m_bisWalking = false;
					npc.m_iChanged_WalkCycle = 3;
					npc.SetActivity("ACT_MP_DEPLOYED_PRIMARY");
					npc.StopPathing();
					npc.m_flSpeed = 150.0;
				}
				if(flDistanceToTarget < npc.GetLeadRadius()) 
				{
					float vPredictedPos[3];
					PredictSubjectPosition(npc, npc.m_iTargetWalkTo,_,_, vPredictedPos);
					npc.SetGoalVector(vPredictedPos);
				}
				else 
				{
					npc.SetGoalEntity(npc.m_iTargetWalkTo);
				}
			}
		}
		
		if(!npc.m_bFUCKYOU)
		{
			if(flDistanceToTarget < npc.GetLeadRadius()) 
			{
				float vPredictedPos[3];
				PredictSubjectPosition(npc, npc.m_iTargetWalkTo,_,_, vPredictedPos);
				npc.SetGoalVector(vPredictedPos);
			}
			else 
			{
				npc.SetGoalEntity(npc.m_iTargetWalkTo);
			}
		}
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTargetWalkTo = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

static Action VictoriaBirdeye_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VictoriaBirdeye npc = view_as<VictoriaBirdeye>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}

	int maxhealth = ReturnEntityMaxHealth(npc.index);
	int health = GetEntProp(npc.index, Prop_Data, "m_iHealth");
	float ratio = float(health) / float(maxhealth);
	if(!npc.Anger && (ratio<0.5 || (float(health)-damage)<(maxhealth*0.5)))
	{
		damage=0.0;
		IncreaseEntityDamageTakenBy(npc.index, 0.000001, 0.2);
		CreateTimer(0.1, Timer_BirdEyeTele, npc.index, TIMER_FLAG_NO_MAPCHANGE);
		npc.Anger = true;
	}
	return Plugin_Changed;
}

static Action Timer_BirdEyeTele(Handle timer, int iNPC)
{
	VictoriaBirdeye npc = view_as<VictoriaBirdeye>(iNPC);
	float Vec[3], VecOld[3];
	GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", VecOld);
	bool FUCKU=false;
	int Decicion = TeleportDiversioToRandLocation(npc.index, true, 1750.0, 1250.0);
	switch(Decicion)
	{
		case 2:
		{
			Decicion = TeleportDiversioToRandLocation(npc.index, true, 1750.0, 625.0);
			if(Decicion == 2)
			{
				Decicion = TeleportDiversioToRandLocation(npc.index, true, 1750.0, 312.5);
				if(Decicion == 2)
				{
					Decicion = TeleportDiversioToRandLocation(npc.index, true, 1750.0, 0.0);
					if(Decicion == 3) FUCKU=true;
				}
				else if(Decicion == 3) FUCKU=true;
			}
			else if(Decicion == 3) FUCKU=true;
		}
		case 3: FUCKU=true;
	}
	if(FUCKU)
	{
		npc.m_flNextIdleSound=0.0;
		npc.PlayIdleAlertSound();
		switch(GetRandomInt(0, 1))
		{
			case 0:NPCPritToChat(npc.index, "{tan}", "birdeye_Talk_07-1", false, false);
			case 1:NPCPritToChat(npc.index, "{tan}", "birdeye_Talk_07-2", false, false);
			case 2:NPCPritToChat(npc.index, "{tan}", "birdeye_Talk_07-3", false, false);
		}
		ApplyStatusEffect(npc.index, npc.index, "Ammo_TM Visualization", 999.0);
		npc.m_flMeleeArmor -= 0.3;
		npc.m_flRangedArmor -= 0.3;
		npc.m_flAttackHappens = 0.0;
		npc.m_bFUCKYOU = true;
	}
	else
	{
		GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", Vec);
		npc.SetGoalVector(Vec, true);
		float SoClose = GetVectorDistance(Vec, VecOld, true);
		if(SoClose < 500.0*500.0)
		{
			npc.m_flNextIdleSound=0.0;
			npc.PlayIdleAlertSound();
			npc.m_flMeleeArmor -= 0.3;
			npc.m_flRangedArmor -= 0.3;
			npc.m_flAttackHappens = 0.0;
			npc.m_bFUCKYOU = true;
			switch(GetRandomInt(0, 1))
			{
				case 0:NPCPritToChat(npc.index, "{tan}", "birdeye_Talk_07-1", false, false);
				case 1:NPCPritToChat(npc.index, "{tan}", "birdeye_Talk_07-2", false, false);
				case 2:NPCPritToChat(npc.index, "{tan}", "birdeye_Talk_07-3", false, false);
			}
			ApplyStatusEffect(npc.index, npc.index, "Ammo_TM Visualization", 999.0);
			TeleportEntity(npc.index, VecOld);
			return Plugin_Stop;
		}
		switch(GetRandomInt(0, 1))
		{
			case 0:NPCPritToChat(npc.index, "{tan}", "birdeye_Talk_06-1", false, false);
			case 1:NPCPritToChat(npc.index, "{tan}", "birdeye_Talk_06-2", false, false);
		}
		ParticleEffectAt(VecOld, "teleported_red", 0.5);
		ParticleEffectAt(Vec, "teleported_blue", 0.5);
		TeleportEntity(npc.index, Vec);
		npc.PlayTeleportSound();
	}
	return Plugin_Stop;
}

static void VictoriaBirdeye_NPCDeath(int entity)
{
	VictoriaBirdeye npc = view_as<VictoriaBirdeye>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}

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

int VictoriaBirdeyeSniperMode(VictoriaBirdeye npc, float gameTime)
{
	if(!npc.m_flAttackHappens)
	{
		if(IsValidEnemy(npc.index,npc.m_iTarget))
		{
			if(!Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
			{
				npc.m_iTarget = GetClosestTarget(npc.index,_,_,_,_,_,_,true,_,_,true);
			}
		}
		else
		{
			npc.m_iTarget = GetClosestTarget(npc.index,_,_,_,_,_,_,true,_,_,true);
			if(!IsValidEnemy(npc.index,npc.m_iTarget))
			{
				return 0;
			}		
		}
		if(!IsValidEnemy(npc.index,npc.m_iTarget))
		{
			return 0;
		}
	}
	/*if(RogueTheme == BlueParadox && i_npcspawnprotection[npc.index] == NPC_SPAWNPROT_ON)
		return 0;*/
		
	float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
	npc.FaceTowards(VecEnemy, 15000.0);

	static float ThrowPos[MAXENTITIES][3];  
	float origin[3], angles[3];
	view_as<CClotBody>(npc.m_iWearable1).GetAttachment("muzzle", origin, angles);
	if(npc.m_flDoingAnimation > gameTime)
	{
		if(Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
		{
			WorldSpaceCenter(npc.m_iTarget, ThrowPos[npc.index]);
			float pos_npc[3];
			WorldSpaceCenter(npc.index, pos_npc);
			float AngleAim[3];
			GetVectorAnglesTwoPoints(pos_npc, ThrowPos[npc.index], AngleAim);
			Handle hTrace = TR_TraceRayFilterEx(pos_npc, AngleAim, MASK_SOLID, RayType_Infinite, BulletAndMeleeTrace, npc.index);
			if(TR_DidHit(hTrace))
			{
				TR_GetEndPosition(ThrowPos[npc.index], hTrace);
			}
		}
	}
	else
	{	
		if(npc.m_flAttackHappens)
		{
			float pos_npc[3];
			WorldSpaceCenter(npc.index, pos_npc);
			float AngleAim[3];
			GetVectorAnglesTwoPoints(pos_npc, ThrowPos[npc.index], AngleAim);
			Handle hTrace = TR_TraceRayFilterEx(pos_npc, AngleAim, MASK_SOLID, RayType_Infinite, BulletAndMeleeTrace, npc.index);
			if(TR_DidHit(hTrace))
			{
				TR_GetEndPosition(ThrowPos[npc.index], hTrace);
			}
			delete hTrace;
		}
	}
	if(npc.m_flAttackHappens)
	{
		TE_SetupBeamPoints(origin, ThrowPos[npc.index], Shared_BEAM_Laser, 0, 0, 0, 0.11, 5.0, 5.0, 0, 0.0, {7,255,255,100}, 3);
		TE_SendToAll(0.0);
	}
			
	npc.FaceTowards(ThrowPos[npc.index], 15000.0);
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			ShootLaser(npc.m_iWearable1, "bullet_tracer02_blue_crit", origin, ThrowPos[npc.index], false );
			float pos_npc[3];
			WorldSpaceCenter(npc.index, pos_npc);
			float AngleAim[3];
			GetVectorAnglesTwoPoints(pos_npc, ThrowPos[npc.index], AngleAim);
			Handle hTrace = TR_TraceRayFilterEx(pos_npc, AngleAim, MASK_SOLID, RayType_Infinite, BulletAndMeleeTrace, npc.index);
			int Traced_Target = TR_GetEntityIndex(hTrace);
			if(Traced_Target > 0)
			{
				WorldSpaceCenter(Traced_Target, ThrowPos[npc.index]);
			}
			else if(TR_DidHit(hTrace))
			{
				TR_GetEndPosition(ThrowPos[npc.index], hTrace);
			}
			delete hTrace;	

			int target = Can_I_See_Enemy(npc.index, npc.m_iTarget,_ ,ThrowPos[npc.index]);
			npc.PlayRangeSound();
			npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY");
			if(IsValidEnemy(npc.index, target))
			{
				float damageDealt = 650.0;
				if(ShouldNpcDealBonusDamage(target))
					damageDealt *= 99.0;
				if(b_TheGoons)
					damageDealt *= 0.33;
				
				SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_BULLET, -1, _, ThrowPos[npc.index]);
				if(!IsValidEnemy(npc.index, target))
				{
					switch(GetRandomInt(0, 1))
					{
						case 0:NPCPritToChat(npc.index, "{tan}", "birdeye_Talk_05-1", false, false);
						case 1:NPCPritToChat(npc.index, "{tan}", "birdeye_Talk_05-2", false, false);
					}
				}
				else
				{
					IncreaseEntityDamageTakenBy(target, 0.5, 5.0, true);
					ApplyStatusEffect(npc.index, target, "Silenced", (IsValidClient(target) ? 5.0 : (b_thisNpcIsARaid[target] || b_thisNpcIsABoss[target] ? 3.0 : 5.0)));
				}
			}
		}
	}

	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(NpcStats_VictorianCallToArms(npc.index))
		{
			npc.m_flAttackHappens = gameTime + (npc.m_iBurst>0 ? 0.2 : 0.65);
		}
		else if(!NpcStats_VictorianCallToArms(npc.index))
		{
			npc.m_flAttackHappens = gameTime + (npc.m_iBurst>0 ? 0.2 : 1.25);
		}
		npc.m_flDoingAnimation = gameTime + 0.95;
		if(b_TheGoons)
		{
			npc.m_iBurst++;
			if(npc.m_iBurst>3)
			{
				npc.m_iAttackCount++;
				npc.m_flNextMeleeAttack = gameTime + 2.5;
				npc.m_iBurst = 0;
				if(npc.m_iAttackCount>=5)
				{
					CreateTimer(0.1, Timer_BirdEyeTele, npc.index, TIMER_FLAG_NO_MAPCHANGE);
					npc.m_iAttackCount=0;
				}
			}
			else
				npc.m_flNextMeleeAttack = gameTime + 0.5;
		}
		else
			npc.m_flNextMeleeAttack = gameTime + 2.5;
	}
	return 1;
}

static int VictoriaBirdeyeAssaultMode(VictoriaBirdeye npc, float gameTime, int target, float distance)
{
	if(npc.m_iAmmo < 1)
		return 4;
	if(gameTime > npc.m_flNextRangedAttack)
	{
		if(npc.m_iAttacksTillReload!=1)
		{
			KillFeed_SetKillIcon(npc.index, "headshot");
			npc.m_iAttacksTillReload=1;
		}
		if(!npc.m_flAttackHappens)
			npc.m_flAttackHappens = gameTime + 0.8;
		if(npc.m_flAttackHappens)
		{
			if(npc.m_flAttackHappens < gameTime)
			{
				npc.PlayRangeSound();
				npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY");
				float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
				npc.FaceTowards(vecTarget, 20000.0);
				Handle swingTrace;
				if(npc.DoSwingTrace(swingTrace, target, { 9999.0, 9999.0, 9999.0 }))
				{
					target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					float origin[3], angles[3];
					view_as<CClotBody>(npc.m_iWearable1).GetAttachment("muzzle", origin, angles);
					ShootLaser(npc.m_iWearable1, "bullet_tracer01_red_crit", origin, vecHit, false);
					if(IsValidEnemy(npc.index, target))
					{
						float damageDealt = 195.0;
						if(ShouldNpcDealBonusDamage(target))
							damageDealt *= 5.0;
						if(b_TheGoons)
							damageDealt *= 0.33;
						SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_BULLET, -1, _, vecHit);
						if(!IsValidEnemy(npc.index, target))
						{
							switch(GetRandomInt(0, 1))
							{
								case 0:NPCPritToChat(npc.index, "{tan}", "birdeye_Talk_05-1", false, false);
								case 1:NPCPritToChat(npc.index, "{tan}", "birdeye_Talk_05-2", false, false);
							}
						}
						else
						{
							IncreaseEntityDamageTakenBy(target, 0.5, 5.0, true);
							ApplyStatusEffect(npc.index, target, "Silenced", (IsValidClient(target) ? 5.0 : (b_thisNpcIsARaid[target] || b_thisNpcIsABoss[target] ? 3.0 : 5.0)));
						}
					}
					if(b_TheGoons)
					{
						npc.m_flAttackHappens = gameTime + 0.2;
						npc.m_iBurst++;
						if(npc.m_iBurst>3)
						{
							npc.m_iBurst = 0;
							npc.m_flNextRangedAttack = gameTime + 20.0;
						}
					}
					else
					{
						npc.m_flNextRangedAttack = gameTime + 20.0;
						npc.m_flAttackHappens = 0.0;
					}
					npc.m_flNextMeleeAttack = gameTime + 2.5;
					npc.m_flCharge_delay = gameTime + 0.8;
					npc.m_iAmmo--;
				}
				delete swingTrace;
			}
		}
		return 6;
	}
	else if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(npc.m_iAttacksTillReload!=2)
		{
			KillFeed_SetKillIcon(npc.index, "pro_rifle");
			npc.m_iAttacksTillReload=2;
		}
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 18.0))
		{
			int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTargetWalkTo);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.PlayRAGEattackSound();
				npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY");
				npc.m_iTargetWalkTo = Enemy_I_See;
				if(ShouldNpcDealBonusDamage(npc.m_iTargetWalkTo))
					b_GotBuilding[npc.index]=true;
				else
					b_GotBuilding[npc.index]=false;
				float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
				npc.FaceTowards(vecTarget, 20000.0);
				Handle swingTrace;
				if(npc.DoSwingTrace(swingTrace, target, { 9999.0, 9999.0, 9999.0 }))
				{
					target = TR_GetEntityIndex(swingTrace);	
						
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					float origin[3], angles[3];
					view_as<CClotBody>(npc.m_iWearable1).GetAttachment("muzzle", origin, angles);
					ShootLaser(npc.m_iWearable1, "bullet_tracer01_red", origin, vecHit, false);
					npc.m_flNextMeleeAttack = gameTime + 0.1;
					npc.m_flCharge_delay = gameTime + 0.8;
					if(IsValidEnemy(npc.index, target))
					{
						float damageDealt = 39.0;
						if(ShouldNpcDealBonusDamage(target))
							damageDealt *= 3.0;
						SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_BULLET, -1, _, vecHit);
						// Killed target
						if(!IsValidEnemy(npc.index, target))
						{
							switch(GetRandomInt(0, 1))
							{
								case 0:NPCPritToChat(npc.index, "{tan}", "birdeye_Talk_05-1", false, false);
								case 1:NPCPritToChat(npc.index, "{tan}", "birdeye_Talk_05-2", false, false);
							}
						}
					}
					npc.m_iAmmo--;
				}
				delete swingTrace;
			}
			if(!npc.m_bFUCKYOU)
				return 5;
			else
			{
				if(distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 15.0) || b_GotBuilding[npc.index])
				{
					//target is too far, try to close in
					return 2;
				}
				else if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 14.0))
				{
					if(Can_I_See_Enemy_Only(npc.index, target))
					{
						//target is too close, try to keep distance
						return 3;
					}
				}
			}
			return 2;
		}
		else
		{
			if(!npc.m_bFUCKYOU)
				return 5;
			else
			{
				if(distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 14.5) || b_GotBuilding[npc.index])
				{
					//target is too far, try to close in
					return 2;
				}
				else if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 13.0))
				{
					if(Can_I_See_Enemy_Only(npc.index, target))
					{
						//target is too close, try to keep distance
						return 3;
					}
				}
			}
		}
	}
	else
	{
		if(!npc.m_bFUCKYOU)
			return 5;
		else
		{
			if(distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 14.5) || b_GotBuilding[npc.index])
			{
				//target is too far, try to close in
				return 2;
			}
			else if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 13.0))
			{
				if(Can_I_See_Enemy_Only(npc.index, target))
				{
					//target is too close, try to keep distance
					return 3;
				}
			}
		}
	}
	return 0;
}

static void VictoriaBirdeye_SpawnAllyDuo(int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(IsValidEntity(entity))
	{
		VictoriaBirdeye npc = view_as<VictoriaBirdeye>(entity);
		float pos[3]; GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);
		float ang[3]; GetEntPropVector(entity, Prop_Data, "m_angRotation", ang);
		int maxhealth;

		maxhealth = GetEntProp(entity, Prop_Data, "m_iHealth");

		int spawn_index = NPC_CreateByName("npc_harbringer", entity, pos, ang, GetTeam(entity), b_TheGoons ? "the_goons" : "birdeye");
		int spawn_index2 = NPC_CreateByName("npc_bigpipe", entity, pos, ang, GetTeam(entity), b_TheGoons ? "the_goons" : "birdeye");
		if(spawn_index > MaxClients)
		{
			NpcStats_CopyStats(entity, spawn_index);
			//i_ally_index = EntIndexToEntRef(spawn_index);
			//VictoriaHarbringer_Set_Ally_Index(entity);
			NpcAddedToZombiesLeftCurrently(spawn_index, true);
			SetEntProp(spawn_index, Prop_Data, "m_iHealth", RoundToFloor(maxhealth*2.5));
			SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", RoundToFloor(maxhealth*2.5));
			fl_Extra_MeleeArmor[spawn_index] = fl_Extra_MeleeArmor[entity];
			fl_Extra_RangedArmor[spawn_index] = fl_Extra_RangedArmor[entity];
			fl_Extra_Speed[spawn_index] = fl_Extra_Speed[entity];
			fl_Extra_Damage[spawn_index] = fl_Extra_Damage[entity];
			i_AmountProjectiles[spawn_index] = npc.index;
			b_thisNpcIsABoss[spawn_index] = b_thisNpcIsABoss[entity];
			npc.m_iHarbringer=spawn_index;
		}
		if(spawn_index2 > MaxClients)
		{
			//i_ally_index = EntIndexToEntRef(spawn_index2);
			//VictoriaBigPipe_Set_Ally_Index(entity);
			NpcAddedToZombiesLeftCurrently(spawn_index2, true);
			SetEntProp(spawn_index2, Prop_Data, "m_iHealth", RoundToFloor(maxhealth*1.5));
			SetEntProp(spawn_index2, Prop_Data, "m_iMaxHealth", RoundToFloor(maxhealth*1.5));
			fl_Extra_MeleeArmor[spawn_index2] = fl_Extra_MeleeArmor[entity];
			fl_Extra_RangedArmor[spawn_index2] = fl_Extra_RangedArmor[entity];
			fl_Extra_Speed[spawn_index2] = fl_Extra_Speed[entity];
			fl_Extra_Damage[spawn_index2] = fl_Extra_Damage[entity];
			i_AmountProjectiles[spawn_index2] = npc.index;
			i_State[spawn_index2] = npc.m_iHarbringer;
			b_thisNpcIsABoss[spawn_index2] = b_thisNpcIsABoss[entity];
			npc.m_iBigPipe=spawn_index2;
			i_State[spawn_index] = spawn_index2;
		}
	}
}