#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] =
{
	"npc/metropolice/die1.wav",
	"npc/metropolice/die2.wav",
	"npc/metropolice/die3.wav",
	"npc/metropolice/die4.wav"
};

static const char g_IdleSounds[][] =
{
	"npc/metropolice/vo/takecover.wav",
	"npc/metropolice/vo/readytojudge.wav",
	"npc/metropolice/vo/subject.wav",
	"npc/metropolice/vo/subjectis505.wav"
};

static const char g_RangedAttackSounds[][] =
{
	"weapons/pistol/pistol_fire2.wav"
};

static const char g_RangedReloadSound[][] =
{
	"weapons/pistol/pistol_reload1.wav"
};

static const char g_IdleAlert[][] =
{
	"npc/metropolice/vo/airwatchsubjectis505.wav",
	"npc/metropolice/vo/allunitscloseonsuspect.wav",
	"npc/metropolice/vo/allunitsmovein.wav",
	"npc/metropolice/vo/breakhiscover.wav",
	"npc/metropolice/vo/destroythatcover.wav"
};

static const char g_WarCry[][] = {
	"mvm/mvm_used_powerup.wav",
};

static float f_GlobalSoundCD;
static bool buffing;

void Barracks_Combine_Commander_Precache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_RangedAttackSounds);
	PrecacheSoundArray(g_RangedReloadSound);
	PrecacheSoundArray(g_IdleAlert);
	PrecacheSoundArray(g_WarCry);
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Barracks Commander");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_barrack_combine_commander");
	data.IconCustom = false;
	
	data.Flags = 0;
	f_GlobalSoundCD = 0.0;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return Barrack_Combine_Commander(client, vecPos, vecAng);
}

methodmap Barrack_Combine_Commander < BarrackBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
	}
	public void PlayIdleAlertSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlert[GetRandomInt(0, sizeof(g_IdleAlert) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		

	}
	public void PlayPistolReload()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayNPCDeath()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayWarCry() 
	{
		if(f_GlobalSoundCD > GetGameTime())
			return;
			
		f_GlobalSoundCD = GetGameTime() + 5.0;

		static int r;
		static int g;
		static int b;
		static int a = 255;
		if(GetTeam(this.index) != TFTeam_Red)
		{
			r = 125;
			g = 125;
			b = 255;
		}
		else
		{
			r = 255;
			g = 125;
			b = 125;
		}
		static float UserLoc[3];
		GetEntPropVector(this.index, Prop_Data, "m_vecAbsOrigin", UserLoc);
		spawnRing(this.index, 35.0 * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 1.3, 6.0, 6.1, 1);
		spawnRing(this.index, 35.0 * 2.0, 0.0, 0.0, 15.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 1.0, 6.0, 6.1, 1);

		EmitSoundToAll(g_WarCry[GetRandomInt(0, sizeof(g_WarCry) - 1)], this.index, SNDCHAN_AUTO, 70, _, 0.35, 100);
	}

	public Barrack_Combine_Commander(int client, float vecPos[3], float vecAng[3])
	{
		Barrack_Combine_Commander npc = view_as<Barrack_Combine_Commander>(BarrackBody(client, vecPos, vecAng, "1250", COMBINE_CUSTOM_MODEL, STEPTYPE_COMBINE,_,_,"models/pickups/pickup_powerup_crit.mdl"));
		
		i_NpcWeight[npc.index] = 1;
		
		func_NPCOnTakeDamage[npc.index] = BarrackBody_OnTakeDamage;
		func_NPCDeath[npc.index] = Barrack_Combine_Commander_NPCDeath;
		func_NPCThink[npc.index] = Barrack_Combine_Commander_ClotThink;
		npc.m_flSpeed = 150.0;

		npc.m_iAttacksTillReload = 6;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flRangedSpecialDelay = 0.0;
		buffing = false;

		
		KillFeed_SetKillIcon(npc.index, "pistol");
		
		int skin = 1;
		
		npc.m_iWearable1 = npc.EquipItem("anim_attachment_RH", "models/weapons/w_pistol.mdl");
		SetVariantString("1.4");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/soldier/tw_soldierbot_helmet/tw_soldierbot_helmet.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		SetEntityRenderColor(npc.m_iWearable2, 175, 175, 175, 255);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/demo/sbox2014_demo_samurai_armour/sbox2014_demo_samurai_armour.mdl");
		SetVariantString("0.8");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/soldier/tw_soldierbot_armor/tw_soldierbot_armor.mdl");
		SetVariantString("1.2");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		SetEntityRenderColor(npc.m_iWearable4, 175, 175, 175, 255);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		
		return npc;
	}
}

public void Barrack_Combine_Commander_ClotThink(int iNPC)
{
	Barrack_Combine_Commander npc = view_as<Barrack_Combine_Commander>(iNPC);
	float GameTime = GetGameTime(iNPC);
	if(BarrackBody_ThinkStart(npc.index, GameTime))
	{
		int client = BarrackBody_ThinkTarget(npc.index, true, GameTime);
		int PrimaryThreatIndex = npc.m_iTarget;

		if(PrimaryThreatIndex > 0)
		{
			npc.PlayIdleAlertSound();
			float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);

			//Can we attack right now?
			if(buffing)
			{
				npc.AddGesture("ACT_METROPOLICE_DEPLOY_MANHACK");
				npc.m_flNextRangedAttack = GameTime + 0.50;
				buffing = false;
				switch(GetRandomInt(0,3))
				{
					case 0:
					{
						NpcSpeechBubble(npc.index, "RUSH!", 5, {255,255,255,255}, {0.0,0.0,60.0}, "");
					}
					case 1:
					{
						NpcSpeechBubble(npc.index, "ATTACK!", 5, {255,255,255,255}, {0.0,0.0,60.0}, "");
					}
					case 2:
					{
						NpcSpeechBubble(npc.index, "FOR GULN!!", 5, {200,0,0,255}, {0.0,0.0,60.0}, "");
					}
					case 3:
					{
						NpcSpeechBubble(npc.index, "NEVER LET THEM ESCAPE!", 5, {255,255,255,255}, {0.0,0.0,60.0}, "");
					}
				}
			}

			if(flDistanceToTarget < 450000.0)
			{
				int Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
				//Target close enough to hit
				if(IsValidEnemy(npc.index, Enemy_I_See))
				{
					if(npc.m_iAttacksTillReload < 1 && !buffing)
					{
						npc.AddGesture("ACT_RELOAD_PISTOL");
						npc.m_flNextRangedAttack = GameTime + 1.35;
						npc.m_iAttacksTillReload = 6;
						npc.PlayPistolReload();
					}
					if((npc.m_iAttacksTillReload > 1 && npc.m_flNextRangedAttack < GameTime && !buffing))
					{
						npc.AddGesture("ACT_DARIO_ATTACK_GUN_1", false);
						npc.m_iTarget = Enemy_I_See;
						npc.PlayRangedSound();
						npc.FaceTowards(vecTarget, 450000.0);
						Handle swingTrace;
						if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex, { 9999.0, 9999.0, 9999.0 }))
						{
							int target = TR_GetEntityIndex(swingTrace);	
								
							float vecHit[3];
							TR_GetEndPosition(vecHit, swingTrace);
							float origin[3], angles[3];
							view_as<CClotBody>(npc.m_iWearable1).GetAttachment("muzzle", origin, angles);
							ShootLaser(npc.m_iWearable1, "bullet_tracer02_red", origin, vecHit, false );
							
							npc.m_flNextRangedAttack = GameTime + (2.00 * npc.BonusFireRate);
							npc.m_iAttacksTillReload -= 1.0;
							
							SDKHooks_TakeDamage(target, npc.index, client, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId), 6400.0, 1), DMG_BULLET, -1, _, vecHit);
						} 		
						delete swingTrace;				
					}
					else
					{
						npc.m_flSpeed = 150.0;
					}
				}
			}
			CommanderAOEBuff(npc,GetGameTime(npc.index));
		}
		else
		{
			npc.PlayIdleSound();
		}

		BarrackBody_ThinkMove(npc.index, 150.0, "ACT_IDLE_BOBPRIME", "ACT_DARIO_WALK", 400000.0,_, true);
	}
}

void CommanderAOEBuff(Barrack_Combine_Commander npc, float gameTime)
{
	float pos1[3];
	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos1);
	if(npc.m_flRangedSpecialDelay < gameTime)
	{
		for(int entitycount; entitycount<MAXENTITIES; entitycount++) //Check for npcs
		{
			if(IsValidEntity(entitycount) && entitycount != npc.index && (!b_NpcHasDied[entitycount])) //Cannot buff self like this.
			{
				if(GetEntProp(entitycount, Prop_Data, "m_iTeamNum") == GetEntProp(npc.index, Prop_Data, "m_iTeamNum") && IsEntityAlive(entitycount))
				{
					static float pos2[3];
					GetEntPropVector(entitycount, Prop_Data, "m_vecAbsOrigin", pos2);
					if(GetVectorDistance(pos1, pos2, true) < (700 * 700))
					{
						ApplyStatusEffect(npc.index, npc.index, "Mazeat Command", 20.0);
						ApplyStatusEffect(npc.index, entitycount, "Mazeat Command", 20.0);
						npc.m_flRangedSpecialDelay = GetGameTime() + 50.0;
						buffing = true;
						npc.PlayWarCry();
						if(entitycount != npc.index)
						{
							float flPos[3]; // original
							Barrack_Combine_Commander npc1 = view_as<Barrack_Combine_Commander>(entitycount);
							GetEntPropVector(entitycount, Prop_Data, "m_vecAbsOrigin", flPos);
							if(IsValidEntity(npc1.m_iWearable8))
								RemoveEntity(npc1.m_iWearable8);
								
							npc1.m_iWearable8 = ParticleEffectAt_Parent(flPos, "coin_blue", npc1.index, "", {0.0,0.0,0.0});
							CreateTimer(10.0, Timer_RemoveEntity, EntIndexToEntRef(npc1.m_iWearable8), TIMER_FLAG_NO_MAPCHANGE);
						}
					}
				}
			}
		}
	}
}

void Barrack_Combine_Commander_NPCDeath(int entity)
{
	Barrack_Combine_Commander npc = view_as<Barrack_Combine_Commander>(entity);
	BarrackBody_NPCDeath(npc.index);
	npc.PlayNPCDeath();
}
/*
public Action Boolchange(Handle Timer)
{
	buffing = false;
}*/