#pragma semicolon 1
#pragma newdecls required
static const char g_IdleAlertedSounds[][] = {
	"vo/spy_battlecry01.mp3",
	"vo/spy_battlecry02.mp3",
	"vo/spy_battlecry03.mp3",
	"vo/spy_battlecry04.mp3",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/blade_hit1.wav",
	"weapons/blade_hit2.wav",
	"weapons/blade_hit3.wav",
	"weapons/blade_hit4.wav",
};

static const char g_TeleportSound[][] = {
	"weapons/rescue_ranger_teleport_receive_01.wav",
	"weapons/rescue_ranger_teleport_receive_02.wav",
};

static const char g_MeleeAttackSounds[] = "weapons/knife_swing.wav";
static const char g_MeleeAttackBackstabSounds[] = "player/spy_shield_break.wav";

static int NPCId;

void CaptinoBaguettus_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Captino Menius");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_captino_baguettus");
	strcopy(data.Icon, sizeof(data.Icon), "captino_agentus");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPCId=NPC_Add(data);
}

int CaptinoBaguettus_ID()
{
	return NPCId;
}

static void ClotPrecache()
{
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_TeleportSound);
	PrecacheSound(g_MeleeAttackSounds);
	PrecacheSound(g_MeleeAttackBackstabSounds);
	
	PrecacheModel("models/player/spy.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return CaptinoBaguettus(vecPos, vecAng, team);
}

methodmap CaptinoBaguettus < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayMeleeBackstabSound(int target)
	{
		if(this.m_flNextBackStepSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_MeleeAttackBackstabSounds, this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, 0.7);
		if(target <= MaxClients)
			EmitSoundToClient(target, g_MeleeAttackBackstabSounds, target, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextBackStepSound = GetGameTime(this.index) + GetRandomFloat(2.0, 4.0);
	}
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds, this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayTeleportSound() 
	{
		EmitSoundToAll(g_TeleportSound[GetRandomInt(0, sizeof(g_TeleportSound) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayCloakSound() 
	{
		EmitSoundToAll("player/spy_cloak.wav", this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayUnCloakSound() 
	{
		EmitSoundToAll("player/spy_uncloak.wav", this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayUnCloakLoudSound() 
	{
		EmitSoundToAll("player/spy_uncloak_feigndeath.wav", this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void SpeechTalk(int client)
	{
		if(this.m_flNextSpeechTalk > GetGameTime(this.index))
			return;
		
		if(GetEntityFlags(client) & FL_FROZEN)
			return;

		switch(GetURandomInt() % 12)
		{
			case 0:
			{
				this.Speech("I wonder why he hasnt send more then just me");
				this.SpeechDelay(5.0, "some plans going on?");
			}
			case 1:
			{
				this.Speech("You guys really should setup your own base at some point.");
				this.SpeechDelay(5.0, "Your work is incredible and helps people all around.");
			}
			case 2:
			{
				this.Speech("Involvement isnt really our thing, but chaos and void have been really bad lately.");
				this.SpeechDelay(5.0, "So we decided to interviene now.");
			}
			case 3:
			{
				this.Speech("Soon the time will come for everyone to not do random wars.");
				this.SpeechDelay(5.0, "But that time isnt now from the looks of it.");
			}
			case 4:
			{
				this.Speech("Sensal is the most kind and high ranking expidonsan youll see.");
				this.SpeechDelay(5.0, "The rest are, as you would say, incredibly racist at those ranks, for maybe even good reasons.");
			}
			case 5:
			{
				this.Speech("im sure at this point you have enough favor to even enter expidonan cities.");
				this.SpeechDelay(5.0, "Thats unheard off, and only two others managed to achive this so far.");
			}
			case 6:
			{
				this.Speech("Expidonsa isnt just our city or country, its varous ones all around.");
				this.SpeechDelay(5.0, "We dont do much contact with eachother because we just often dont agree on things.");
				this.SpeechDelay(10.0, "so instead of conflicts, we just live with an oath we made, to help when the planet is in danger.");
			}
			case 7:
			{
				this.Speech("Expidonsa is more like an underground Agent center");
				this.SpeechDelay(5.0, "we take out alien threads and bad guys without most knowing.");
				this.SpeechDelay(10.0, "Why? History would tell you, but im not authorized to tell.");
			}
			case 8:
			{
				this.Speech("Bob is one of the only few people that align their interrests with expidonsa's");
				this.SpeechDelay(5.0, "Intentionally or not, hes extremaly helpfull, we like to lend him a hand or two without him knowing.");
				this.SpeechDelay(10.0, "like the time he put away bladedance, we gave him a little extra energy so it would work.");
			}
			case 9:
			{
				this.Speech("kahmlstein was on the verge of being as intelligent as an average expidonsan.");
				this.SpeechDelay(5.0, "its scary to think about what one would do without our morale code.");
			}
			case 10:
			{
				this.Speech("The time we attacked eachother? that wasnt fake, you did kill some of us.");
				this.SpeechDelay(5.0, "But so did we kill some of yours, some will want revenge on you, thats for sure.");
				this.SpeechDelay(10.0, "We see this as a missfire, its moreso that its not worth it to continune when instead we can help eachother.");
			}
			case 11:
			{
				this.Speech("The hiarchy of expidonsa is mostly willing, most dont want all that work.");
				this.SpeechDelay(5.0, "some do like sensal and so on.");
				this.SpeechDelay(10.0, "they are greatly appreciated for it.");

			}
		}
		
		this.m_flNextSpeechTalk = GetGameTime(this.index) + GetRandomFloat(36.0, 48.0);
	}
	public void SpeechDelay(float time, const char[] speechtext, const char[] endingtextscroll = "")
	{
		DataPack pack;
		CreateDataTimer(time, BaguettusFollower_SpeechTimer, pack, TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(EntIndexToEntRef(this.index));
		pack.WriteString(speechtext);
		pack.WriteString(endingtextscroll);
	}
	public void Speech(const char[] speechtext, const char[] endingtextscroll = "")
	{
		NpcSpeechBubble(this.index, speechtext, 5, {255, 255, 255, 255}, {0.0,0.0,85.0}, endingtextscroll);
	}
	
	property float m_flGetClosestTargetAllyTime
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flNextSpeechTalk
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flNextBackStepSound
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property float m_flCaptinoMeniusTeleportForAlly
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	property float m_flCaptinoMeniusTeleportForEnemy
	{
		public get()							{ return fl_AbilityOrAttack[this.index][4]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][4] = TempValueForProperty; }
	}
	
	public CaptinoBaguettus(float vecPos[3], float vecAng[3], int ally)
	{
		CaptinoBaguettus npc = view_as<CaptinoBaguettus>(CClotBody(vecPos, vecAng, "models/player/spy.mdl", "1.0", "750", ally, true, true));
		
		i_NpcWeight[npc.index] = 3;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("selectionMenu_Idle");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_flNextMeleeAttack = 0.0;
		npc.g_TimesSummoned = 0;
		npc.m_iAttacksTillMegahit = 0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		func_NPCDeath[npc.index] = CaptinoBaguettus_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCThink[npc.index] = CaptinoBaguettus_ClotThink;
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		npc.m_flCaptinoMeniusTeleportForAlly = 0.0;
		npc.m_flCaptinoMeniusTeleportForEnemy = 0.0;
		npc.m_bCamo = false;
		npc.Anger = false;
		npc.m_bFUCKYOU = false;
		npc.m_bDissapearOnDeath = true;
		b_NpcIsInvulnerable[npc.index] = true;
		b_NoKillFeed[npc.index] = true;
		
		b_ThisNpcIsImmuneToNuke[npc.index] = true;
		b_NoKnockbackFromSources[npc.index] = true;
		b_ThisEntityIgnored[npc.index] = true;
		MakeObjectIntangeable(npc.index);
		b_NoHealthbar[npc.index]=2;
		
		npc.m_flNextIdleSound = GetGameTime(npc.index) + 30.0;
		npc.m_flNextSpeechTalk = GetGameTime(npc.index) + 10.0;
		
		int skin = (ZR_Get_Modifier()==2 ? 1 : 0);
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_eternal_reward/c_eternal_reward.mdl");

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop_partner/player/items/all_class/dex_glasses/dex_glasses_spy.mdl");

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/spy/majors_mark/majors_mark.mdl");

		npc.m_iWearable4 = npc.EquipItem("head", "models/player/items/all_class/all_halo.mdl");

		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/spy/hwn2022_turncoat/hwn2022_turncoat.mdl");

		npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/demo/dec24_top_brass_style1/dec24_top_brass_style1.mdl");
		SetVariantString("1.2");
		AcceptEntityInput(npc.m_iWearable6, "SetModelScale");

		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", skin);

		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 255, 255, 255, 1);
		SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 1);
		SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable2, 255, 255, 255, 1);
		SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable3, 255, 255, 255, 1);
		SetEntityRenderMode(npc.m_iWearable4, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable4, 255, 255, 255, 1);
		SetEntityRenderMode(npc.m_iWearable5, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable5, 255, 255, 255, 1);
		SetEntityRenderMode(npc.m_iWearable6, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable6, 255, 255, 255, 1);
		
		SetEntPropFloat(npc.index, Prop_Send, "m_fadeMinDist", 1.0);
		SetEntPropFloat(npc.index, Prop_Send, "m_fadeMaxDist", 1.0);
		SetEntPropFloat(npc.m_iWearable1, Prop_Send, "m_fadeMinDist", 1.0);
		SetEntPropFloat(npc.m_iWearable1, Prop_Send, "m_fadeMaxDist", 1.0);
		SetEntPropFloat(npc.m_iWearable2, Prop_Send, "m_fadeMinDist", 1.0);
		SetEntPropFloat(npc.m_iWearable2, Prop_Send, "m_fadeMaxDist", 1.0);
		SetEntPropFloat(npc.m_iWearable3, Prop_Send, "m_fadeMinDist", 1.0);
		SetEntPropFloat(npc.m_iWearable3, Prop_Send, "m_fadeMaxDist", 1.0);
		SetEntPropFloat(npc.m_iWearable4, Prop_Send, "m_fadeMinDist", 1.0);
		SetEntPropFloat(npc.m_iWearable4, Prop_Send, "m_fadeMaxDist", 1.0);
		SetEntPropFloat(npc.m_iWearable5, Prop_Send, "m_fadeMinDist", 1.0);
		SetEntPropFloat(npc.m_iWearable5, Prop_Send, "m_fadeMaxDist", 1.0);
		SetEntPropFloat(npc.m_iWearable6, Prop_Send, "m_fadeMinDist", 1.0);
		SetEntPropFloat(npc.m_iWearable6, Prop_Send, "m_fadeMaxDist", 1.0);
		
		npc.m_bDoSpawnGesture = true;

		return npc;
	}
}

public void CaptinoBaguettus_ClotThink(int iNPC)
{
	CaptinoBaguettus npc = view_as<CaptinoBaguettus>(iNPC);
	float GameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > GameTime)
		return;
	npc.m_flNextDelayTime = GameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(npc.m_bDoSpawnGesture)
	{
		switch(npc.g_TimesSummoned)
		{
			case 0:
			{
				npc.StopPathing();
				npc.m_bisWalking = false;
				npc.m_flSpeed = 0.0;
				npc.m_iChanged_WalkCycle = -1;
				npc.AddActivityViaSequence("SelectionMenu_Anim01");
				npc.SetCycle(0.01);
				npc.SetPlaybackRate(1.0);
				b_NoHealthbar[npc.index] = 1;
				if(IsValidEntity(npc.m_iTeamGlow))
					RemoveEntity(npc.m_iTeamGlow);
				/*float flPos[3];
				float flAng[3];
				GetAttachment(npc.index, "head", flPos, flAng);	
				int particler = ParticleEffectAt(flPos, "spy_start_disguise_red", 5.0);
				SetParent(npc.index, particler, "head");*/
				npc.PlayUnCloakLoudSound();
				SetEntPropFloat(npc.index, Prop_Send, "m_fadeMinDist", 0.0);
				SetEntPropFloat(npc.index, Prop_Send, "m_fadeMaxDist", 0.0);
				SetEntPropFloat(npc.m_iWearable1, Prop_Send, "m_fadeMinDist", 0.0);
				SetEntPropFloat(npc.m_iWearable1, Prop_Send, "m_fadeMaxDist", 0.0);
				SetEntPropFloat(npc.m_iWearable2, Prop_Send, "m_fadeMinDist", 0.0);
				SetEntPropFloat(npc.m_iWearable2, Prop_Send, "m_fadeMaxDist", 0.0);
				SetEntPropFloat(npc.m_iWearable3, Prop_Send, "m_fadeMinDist", 0.0);
				SetEntPropFloat(npc.m_iWearable3, Prop_Send, "m_fadeMaxDist", 0.0);
				SetEntPropFloat(npc.m_iWearable4, Prop_Send, "m_fadeMinDist", 0.0);
				SetEntPropFloat(npc.m_iWearable4, Prop_Send, "m_fadeMaxDist", 0.0);
				SetEntPropFloat(npc.m_iWearable5, Prop_Send, "m_fadeMinDist", 0.0);
				SetEntPropFloat(npc.m_iWearable5, Prop_Send, "m_fadeMaxDist", 0.0);
				SetEntPropFloat(npc.m_iWearable6, Prop_Send, "m_fadeMinDist", 0.0);
				SetEntPropFloat(npc.m_iWearable6, Prop_Send, "m_fadeMaxDist", 0.0);
				npc.g_TimesSummoned=1;
			}
			case 255:
			{
				/*if(IsValidEntity(npc.m_iWearable7))
					RemoveEntity(npc.m_iWearable7);*/
				b_NoHealthbar[npc.index] = 0;
				if(IsValidEntity(npc.m_iTeamGlow))
					RemoveEntity(npc.m_iTeamGlow);
				npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
				
				SetVariantColor(view_as<int>({184, 56, 59, 200}));
				AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
				npc.m_bDoSpawnGesture=false;
			}
			default:
			{
				npc.g_TimesSummoned+=2;
				if(npc.g_TimesSummoned>255) npc.g_TimesSummoned=255;
				SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.index, 255, 255, 255, npc.g_TimesSummoned);
				SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, npc.g_TimesSummoned);
				SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable2, 255, 255, 255, npc.g_TimesSummoned);
				SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable3, 255, 255, 255, npc.g_TimesSummoned);
				SetEntityRenderMode(npc.m_iWearable4, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable4, 255, 255, 255, npc.g_TimesSummoned);
				SetEntityRenderMode(npc.m_iWearable5, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable5, 255, 255, 255, npc.g_TimesSummoned);
				SetEntityRenderMode(npc.m_iWearable6, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable6, 255, 255, 255, npc.g_TimesSummoned);
			}
		}
		return;
	}
	
	if(npc.m_bFUCKYOU)
	{
		switch(npc.g_TimesSummoned)
		{
			case -1:
			{
				/*none*/
			}
			case 0:
			{
				if(AlreadySaidWin)
				{
					NPCPritToChat_Noname("CaptinoMenius_Talk-2", false);
					npc.g_TimesSummoned=-1;
				}
				else
				{
					bool ValidZenZal;
					for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
					{
						int IsZenZal = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);
						if(IsValidEntity(IsZenZal) && i_NpcInternalId[IsZenZal] == SensalNPCID() && !b_NpcHasDied[IsZenZal])
						{
							npc.m_iTargetAlly=IsZenZal;
							ValidZenZal=true;
							break;
						}
					}
					if(ValidZenZal)
					{
						b_NoHealthbar[npc.index] = 0;
						if(IsValidEntity(npc.m_iTeamGlow))
							RemoveEntity(npc.m_iTeamGlow);
						npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
						
						SetVariantColor(view_as<int>({184, 56, 59, 200}));
						AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
						npc.PlayUnCloakSound();
					/*	float flPos[3];
						float flAng[3];
						GetAttachment(npc.index, "head", flPos, flAng);	
						int particler = ParticleEffectAt(flPos, "spy_start_disguise_red", 5.0);
						SetParent(npc.index, particler, "head");*/
						SetEntPropFloat(npc.index, Prop_Send, "m_fadeMinDist", 0.0);
						SetEntPropFloat(npc.index, Prop_Send, "m_fadeMaxDist", 0.0);
						SetEntPropFloat(npc.m_iWearable1, Prop_Send, "m_fadeMinDist", 0.0);
						SetEntPropFloat(npc.m_iWearable1, Prop_Send, "m_fadeMaxDist", 0.0);
						SetEntPropFloat(npc.m_iWearable2, Prop_Send, "m_fadeMinDist", 0.0);
						SetEntPropFloat(npc.m_iWearable2, Prop_Send, "m_fadeMaxDist", 0.0);
						SetEntPropFloat(npc.m_iWearable3, Prop_Send, "m_fadeMinDist", 0.0);
						SetEntPropFloat(npc.m_iWearable3, Prop_Send, "m_fadeMaxDist", 0.0);
						SetEntPropFloat(npc.m_iWearable4, Prop_Send, "m_fadeMinDist", 0.0);
						SetEntPropFloat(npc.m_iWearable4, Prop_Send, "m_fadeMaxDist", 0.0);
						SetEntPropFloat(npc.m_iWearable5, Prop_Send, "m_fadeMinDist", 0.0);
						SetEntPropFloat(npc.m_iWearable5, Prop_Send, "m_fadeMaxDist", 0.0);
						SetEntPropFloat(npc.m_iWearable6, Prop_Send, "m_fadeMinDist", 0.0);
						SetEntPropFloat(npc.m_iWearable6, Prop_Send, "m_fadeMaxDist", 0.0);
						npc.m_bAllowBackWalking = false;
						npc.m_bFUCKYOU=false;
						npc.Anger=true;
					}
				}
			}
			default:
			{
				npc.g_TimesSummoned--;
				if(npc.g_TimesSummoned<=1)
				{
					npc.g_TimesSummoned=0;
					npc.SetActivity("ACT_MP_STAND_MELEE");
					if(IsValidEntity(npc.m_iWearable1))
						RemoveEntity(npc.m_iWearable1);
					npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_eternal_reward/c_eternal_reward.mdl");
					/*if(IsValidEntity(npc.m_iWearable7))
						RemoveEntity(npc.m_iWearable7);*/
					SetEntPropFloat(npc.index, Prop_Send, "m_fadeMinDist", 1.0);
					SetEntPropFloat(npc.index, Prop_Send, "m_fadeMaxDist", 1.0);
					SetEntPropFloat(npc.m_iWearable1, Prop_Send, "m_fadeMinDist", 1.0);
					SetEntPropFloat(npc.m_iWearable1, Prop_Send, "m_fadeMaxDist", 1.0);
					SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
					SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 0);
					SetEntPropFloat(npc.m_iWearable2, Prop_Send, "m_fadeMinDist", 1.0);
					SetEntPropFloat(npc.m_iWearable2, Prop_Send, "m_fadeMaxDist", 1.0);
					SetEntPropFloat(npc.m_iWearable3, Prop_Send, "m_fadeMinDist", 1.0);
					SetEntPropFloat(npc.m_iWearable3, Prop_Send, "m_fadeMaxDist", 1.0);
					SetEntPropFloat(npc.m_iWearable4, Prop_Send, "m_fadeMinDist", 1.0);
					SetEntPropFloat(npc.m_iWearable4, Prop_Send, "m_fadeMaxDist", 1.0);
					SetEntPropFloat(npc.m_iWearable5, Prop_Send, "m_fadeMinDist", 1.0);
					SetEntPropFloat(npc.m_iWearable5, Prop_Send, "m_fadeMaxDist", 1.0);
					SetEntPropFloat(npc.m_iWearable6, Prop_Send, "m_fadeMinDist", 1.0);
					SetEntPropFloat(npc.m_iWearable6, Prop_Send, "m_fadeMaxDist", 1.0);
					npc.g_TimesSummoned=0;
				}
				else if(!npc.m_bCamo&&npc.g_TimesSummoned>=124)
				{
					b_NoHealthbar[npc.index] = 1;
					if(IsValidEntity(npc.m_iTeamGlow))
						RemoveEntity(npc.m_iTeamGlow);
					if(IsValidEntity(npc.m_iWearable1))
						RemoveEntity(npc.m_iWearable1);
					npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/spy/tailored_terminal_model/tailored_terminal_model.mdl");
					/*float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
					npc.m_iWearable7 = ParticleEffectAt_Parent(VecSelfNpc, "spy_start_disguise_red", npc.index, "pelvis", {0.0,0.0,0.0});*/
					if(npc.m_iChanged_WalkCycle != 2)
					{
						npc.StopPathing();
						npc.m_bisWalking = false;
						npc.m_flSpeed = 0.0;
						npc.m_iChanged_WalkCycle = 2;
						npc.AddActivityViaSequence("taunttailored_terminal_intro");
						npc.SetCycle(0.01);
						npc.SetPlaybackRate(1.0);
					}
					NPCPritToChat(npc.index, "{paleturquoise}", "CaptinoMenius_Talk-1", false, false);
					npc.PlayCloakSound();
					npc.m_bCamo=true;
				}
				SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.index, 255, 255, 255, npc.g_TimesSummoned);
				SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, npc.g_TimesSummoned);
				SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable2, 255, 255, 255, npc.g_TimesSummoned);
				SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable3, 255, 255, 255, npc.g_TimesSummoned);
				SetEntityRenderMode(npc.m_iWearable4, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable4, 255, 255, 255, npc.g_TimesSummoned);
				SetEntityRenderMode(npc.m_iWearable5, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable5, 255, 255, 255, npc.g_TimesSummoned);
				SetEntityRenderMode(npc.m_iWearable6, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable6, 255, 255, 255, npc.g_TimesSummoned);
			}
		}
		return;
	}
	else if(npc.Anger)
	{
		switch(npc.g_TimesSummoned)
		{
			case 255:
			{
				if(IsValidAlly(npc.index, npc.m_iTargetAlly))
				{
					float vecTarget[3]; WorldSpaceCenter(npc.m_iTargetAlly, vecTarget);
					float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
					float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
					static bool ReAnim;
					switch((!Can_I_See_Ally(npc.index, npc.m_iTargetAlly) || flDistanceToTarget > NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED*3.7) ? 0 : 1)
					{
						case 0:
						{
							if(npc.m_iChanged_WalkCycle != 0)
							{
								npc.StartPathing();
								npc.m_bisWalking = true;
								npc.m_flSpeed = 340.0;
								npc.m_iChanged_WalkCycle = 0;
								ReAnim=true;
							}
							BaguettusIntoAir(npc, ReAnim);
							if(flDistanceToTarget < npc.GetLeadRadius())
							{
								float vPredictedPos[3]; PredictSubjectPosition(npc, npc.m_iTargetAlly,_,_, vPredictedPos);
								npc.SetGoalVector(vPredictedPos);
							}
							else
								npc.SetGoalEntity(npc.m_iTargetAlly);
						}
						case 1:
						{
							if(npc.m_iChanged_WalkCycle != 1)
							{
								npc.StopPathing();
								npc.m_bisWalking = false;
								npc.m_flSpeed = 0.0;
								npc.m_iChanged_WalkCycle = 1;
								ReAnim=true;
								npc.SetActivity("ACT_MP_STAND_MELEE");
							}
						}
					}
				}
				else
					SmiteNpcToDeath(npc.index);
			}
			default:
			{
				npc.g_TimesSummoned+=2;
				if(npc.g_TimesSummoned>255)
				{
					/*if(IsValidEntity(npc.m_iWearable7))
						RemoveEntity(npc.m_iWearable7);*/
					npc.g_TimesSummoned=255;
				}
				SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.index, 255, 255, 255, npc.g_TimesSummoned);
				SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, npc.g_TimesSummoned);
				SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable2, 255, 255, 255, npc.g_TimesSummoned);
				SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable3, 255, 255, 255, npc.g_TimesSummoned);
				SetEntityRenderMode(npc.m_iWearable4, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable4, 255, 255, 255, npc.g_TimesSummoned);
				SetEntityRenderMode(npc.m_iWearable5, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable5, 255, 255, 255, npc.g_TimesSummoned);
				SetEntityRenderMode(npc.m_iWearable6, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable6, 255, 255, 255, npc.g_TimesSummoned);
			}
		}
		return;
	}
	if(Waves_Started() && !Waves_InSetup())
	{
		switch(npc.g_TimesSummoned)
		{
			case 255:
			{
				npc.PlayCloakSound();
				npc.g_TimesSummoned--;
			}
			case 125:
			{
				/*none*/
			}
			default:
			{
				npc.g_TimesSummoned-=3;
				if(npc.g_TimesSummoned<125) npc.g_TimesSummoned=125;
				SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.index, 255, 255, 255, npc.g_TimesSummoned);
				SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, npc.g_TimesSummoned);
				SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable2, 255, 255, 255, npc.g_TimesSummoned);
				SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable3, 255, 255, 255, npc.g_TimesSummoned);
				SetEntityRenderMode(npc.m_iWearable4, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable4, 255, 255, 255, npc.g_TimesSummoned);
				SetEntityRenderMode(npc.m_iWearable5, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable5, 255, 255, 255, npc.g_TimesSummoned);
				SetEntityRenderMode(npc.m_iWearable6, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable6, 255, 255, 255, npc.g_TimesSummoned);
			}
		}
	}
	else
	{
		switch(npc.g_TimesSummoned)
		{
			case 255:
			{
				/*none*/
			}
			case 125:
			{
				npc.PlayUnCloakSound();
				npc.g_TimesSummoned++;
			}
			default:
			{
				npc.g_TimesSummoned+=3;
				if(npc.g_TimesSummoned>255) npc.g_TimesSummoned=255;
				SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.index, 255, 255, 255, npc.g_TimesSummoned);
				SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, npc.g_TimesSummoned);
				SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable2, 255, 255, 255, npc.g_TimesSummoned);
				SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable3, 255, 255, 255, npc.g_TimesSummoned);
				SetEntityRenderMode(npc.m_iWearable4, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable4, 255, 255, 255, npc.g_TimesSummoned);
				SetEntityRenderMode(npc.m_iWearable5, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable5, 255, 255, 255, npc.g_TimesSummoned);
				SetEntityRenderMode(npc.m_iWearable6, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable6, 255, 255, 255, npc.g_TimesSummoned);
			}
		}
	}
	
	if(npc.m_flNextThinkTime > GameTime)
		return;
	npc.m_flNextThinkTime = GameTime + 0.1;
	
	if(!IsValidAlly(npc.index, npc.m_iTargetAlly) || npc.m_flGetClosestTargetAllyTime < GameTime)
	{
		npc.m_iTargetAlly = GetClosestAlly(npc.index);
		npc.m_flGetClosestTargetAllyTime = GameTime + GetRandomRetargetTime();
	}

	if(npc.m_flGetClosestTargetTime < GameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GameTime + GetRandomRetargetTime();
	}
	static bool ReAnim;
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		int AntiCheeseReply = 0;
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
	
		npc.m_bAllowBackWalking = false;
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3];
			b_TryToAvoidTraverse[npc.index] = false;
			PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
			vPredictedPos = GetBehindTarget(npc.m_iTarget, 30.0 ,vPredictedPos);
			AntiCheeseReply = DiversionAntiCheese(npc.m_iTarget, npc.index, vPredictedPos);
			b_TryToAvoidTraverse[npc.index] = true;
			if(AntiCheeseReply == 0)
			{
				if(!npc.m_bPathing)
					npc.StartPathing();

				npc.SetGoalVector(vPredictedPos, true);
			}
			else if(AntiCheeseReply == 1)
			{
				if(!npc.m_bPathing)
					npc.StartPathing();
				if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 2.5))
				{
					npc.m_bAllowBackWalking = true;
					float vBackoffPos[3];
					BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget,_,vBackoffPos);
					npc.SetGoalVector(vBackoffPos, true);
				}
				else
				{
					npc.SetGoalEntity(npc.m_iTarget);
				}
			}
		}
		else 
		{
			DiversionCalmDownCheese(npc.index);
			if(!npc.m_bPathing)
				npc.StartPathing();

			npc.SetGoalEntity(npc.m_iTarget);
		}
		if(npc.m_iChanged_WalkCycle != 0)
		{
			npc.StartPathing();
			npc.m_bisWalking = true;
			npc.m_flSpeed = 340.0;
			npc.m_iChanged_WalkCycle = 0;
			ReAnim=true;
		}
		BaguettusIntoAir(npc, ReAnim);
		CaptinoBaguettusBackup(npc, GameTime, flDistanceToTarget);
		npc.m_flNextSpeechTalk = GameTime + 10.0;
	}
	else
	{
		if(IsValidAlly(npc.index, npc.m_iTargetAlly))
		{
			if(!Can_I_See_Ally(npc.index, npc.m_iTargetAlly))
				npc.m_flGetClosestTargetAllyTime -= 0.076;
			npc.m_bAllowBackWalking = false;
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTargetAlly, vecTarget);
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
			if(GameTime > npc.m_flCaptinoMeniusTeleportForAlly && flDistanceToTarget > NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED*150.0)
			{
				static float hullcheckmaxs[3];
				static float hullcheckmins[3];
				hullcheckmaxs = view_as<float>( { 30.0, 30.0, 120.0 } );
				hullcheckmins = view_as<float>( { -30.0, -30.0, 0.0 } );
				if(Npc_Teleport_Safe(npc.index, vecTarget, hullcheckmins, hullcheckmaxs, false))
				{
					ParticleEffectAt(VecSelfNpc, "teleported_red", 0.5);
					WorldSpaceCenter(npc.index, VecSelfNpc);
					ParticleEffectAt(VecSelfNpc, "teleported_red", 0.5);
					npc.m_flCaptinoMeniusTeleportForAlly = GameTime + 18.5;
					npc.PlayTeleportSound();
				}
				else
					npc.m_flCaptinoMeniusTeleportForAlly = GameTime + 1.0;
			}
			switch((!Can_I_See_Ally(npc.index, npc.m_iTargetAlly) || flDistanceToTarget > NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED*3.7) ? 0 : 1)
			{
				case 0:
				{
					if(npc.m_iChanged_WalkCycle != 0)
					{
						npc.StartPathing();
						npc.m_bisWalking = true;
						npc.m_flSpeed = 340.0;
						npc.m_iChanged_WalkCycle = 0;
						ReAnim=true;
					}
					BaguettusIntoAir(npc, ReAnim);
					if(flDistanceToTarget < npc.GetLeadRadius())
					{
						float vPredictedPos[3]; PredictSubjectPosition(npc, npc.m_iTargetAlly,_,_, vPredictedPos);
						npc.SetGoalVector(vPredictedPos);
					}
					else
						npc.SetGoalEntity(npc.m_iTargetAlly);
				}
				case 1:
				{
					if(npc.m_iChanged_WalkCycle != 1)
					{
						npc.StopPathing();
						npc.m_bisWalking = false;
						npc.m_flSpeed = 0.0;
						npc.m_iChanged_WalkCycle = 1;
						ReAnim=true;
						npc.SetActivity("ACT_MP_STAND_MELEE");
					}
				}
			}
			npc.SpeechTalk(npc.m_iTargetAlly);
		}
		else
			npc.m_flGetClosestTargetAllyTime = 0.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.PlayIdleAlertSound();
	}
}

static void CaptinoBaguettusBackup(CaptinoBaguettus npc, float gameTime, float distance)
{
	bool BackstabDone = false;
	if(gameTime > npc.m_flCaptinoMeniusTeleportForEnemy)
	{
		bool TotalFailed;
		for(int AllyLoop; AllyLoop <= MaxClients; AllyLoop ++)
		{
			if(IsValidAlly(npc.index, AllyLoop))
				continue;
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTargetAlly, vecTarget);
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			GetEntPropVector(AllyLoop, Prop_Send, "m_vecOrigin", vecTarget);
			if(GetVectorDistance(VecSelfNpc, vecTarget, true) > NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED*150.0)
				continue;
			Explode_Logic_Custom(0.0, npc.index, npc.index, -1, vecTarget, _, _, _, true, _, false, _, GetNPCCount);
			if(npc.m_iAttacksTillMegahit>=8)
			{
				static float hullcheckmaxs[3];
				static float hullcheckmins[3];
				hullcheckmaxs = view_as<float>( { 30.0, 30.0, 120.0 } );
				hullcheckmins = view_as<float>( { -30.0, -30.0, 0.0 } );
				if(Npc_Teleport_Safe(npc.index, vecTarget, hullcheckmins, hullcheckmaxs, false))
				{
					ParticleEffectAt(VecSelfNpc, "teleported_red", 0.5);
					WorldSpaceCenter(npc.index, VecSelfNpc);
					ParticleEffectAt(VecSelfNpc, "teleported_red", 0.5);
					npc.m_flCaptinoMeniusTeleportForEnemy = gameTime + 60.0;
					npc.PlayTeleportSound();
					npc.m_flGetClosestTargetTime = 0.0;
					ApplyStatusEffect(npc.index, npc.index, "Tonic Affliction", 3.0);
					npc.m_flNextMeleeAttack = gameTime + 1.4;
				}
				else
					npc.m_flCaptinoMeniusTeleportForEnemy = gameTime + 1.0;
				TotalFailed=false;
				break;
			}
			npc.m_iAttacksTillMegahit=0;
			TotalFailed=true;
		}
		if(TotalFailed)
			npc.m_flCaptinoMeniusTeleportForEnemy = gameTime + 5.0;
	}
	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
		{
			int Enemy_I_See;					
			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
			
			float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.PlayMeleeSound();
				if(IsBehindAndFacingTarget(npc.index, npc.m_iTarget))
				{
					BackstabDone = true;
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_SECONDARY");	
				}
				else
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
				npc.m_flAttackHappens = 1.0;
				npc.m_flDoingAnimation = gameTime + 0.25;
				npc.m_flNextMeleeAttack = gameTime + 1.5;
			}
		}
	}
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			Handle swingTrace;
			if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, 1))
			{
				int target = TR_GetEntityIndex(swingTrace);	
				
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				
				if(IsValidEnemy(npc.index, target))
				{
					float damageDealt = 50.0;
					KillFeed_SetKillIcon(npc.index, "eternal_reward");
					if(BackstabDone)
					{
						KillFeed_SetKillIcon(npc.index, "backsteab");
						npc.PlayMeleeBackstabSound(target);
						damageDealt *= 3.0;
					}
					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);
					npc.PlayMeleeHitSound();
				} 
			}
			delete swingTrace;
		}
	}
}

static void GetNPCCount(int entity, int victim, float damage, int weapon)
{
	CaptinoBaguettus npc = view_as<CaptinoBaguettus>(entity);
	if(IsValidEntity(npc.index) && IsValidEntity(victim) && !IsValidClient(victim) && GetTeam(npc.index) != GetTeam(victim))
	{
		npc.m_iAttacksTillMegahit++;
	}
}

public void CaptinoBaguettus_NPCDeath(int entity)
{
	CaptinoBaguettus npc = view_as<CaptinoBaguettus>(entity);
	
	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	ParticleEffectAt(VecSelfNpc, "teleported_red", 0.5);
	npc.PlayTeleportSound();
	
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

static void BaguettusIntoAir(CaptinoBaguettus npc, bool ReAime)
{
	static bool ImAirBone;
	switch(npc.m_iChanged_WalkCycle)
	{
		case 0, 1:
		{
			if(npc.IsOnGround())
			{
				if(!ImAirBone||ReAime)
				{
					npc.SetActivity("ACT_MP_RUN_MELEE");
					ImAirBone=true;
				}
			}
			else
			{
				if(ImAirBone||ReAime)
				{
					npc.SetActivity("ACT_MP_JUMP_FLOAT_MELEE");
					ImAirBone=false;
				}
			}
		}
	}
}

static Action BaguettusFollower_SpeechTimer(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	if(entity != -1)
	{
		char speechtext[128], endingtextscroll[10];
		pack.ReadString(speechtext, sizeof(speechtext));
		pack.ReadString(endingtextscroll, sizeof(endingtextscroll));
		view_as<CaptinoBaguettus>(entity).Speech(speechtext, endingtextscroll);
	}
	return Plugin_Stop;
}