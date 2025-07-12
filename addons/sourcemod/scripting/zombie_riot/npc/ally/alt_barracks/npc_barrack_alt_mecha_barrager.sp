#pragma semicolon 1
#pragma newdecls required

static const char g_RangedAttackSounds[][] = {
	"weapons/bison_main_shot_01.wav",
	"weapons/bison_main_shot_02.wav",
};
static const char g_IdleSounds[][] =
{
	"vo/mvm/norm/taunts/soldier_mvm_taunts01.mp3",
	"vo/mvm/norm/taunts/soldier_mvm_taunts09.mp3",
	"vo/mvm/norm/taunts/soldier_mvm_taunts14.mp3",
};

static const char g_IdleAlertedSounds[][] =
{
	"vo/mvm/norm/taunts/soldier_mvm_taunts18.mp3",
	"vo/mvm/norm/taunts/soldier_mvm_taunts19.mp3",
	"vo/mvm/norm/taunts/soldier_mvm_taunts20.mp3",
	"vo/mvm/norm/taunts/soldier_mvm_taunts21.mp3",
};
static const char g_RangedReloadSound[][] = {
	"weapons/bison_reload.wav",
};
static float fl_npc_basespeed;

public void Barrack_Alt_Mecha_Barrager_MapStart()
{
	PrecacheModel("models/player/medic.mdl");
	PrecacheSoundArray(g_RangedAttackSounds);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_RangedReloadSound);

	PrecacheModel("models/bots/soldier/bot_soldier.mdl", true);

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Barracks Mecha Barrager");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_barrack_alt_mecha_barrager");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return Barrack_Alt_Mecha_Barrager(client, vecPos, vecAng);
}




methodmap Barrack_Alt_Mecha_Barrager < BarrackBody
{

	public void PlayIdleAlertSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		

	}
	public void PlayRangedReloadSound() {
		EmitSoundToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		

	}
	public Barrack_Alt_Mecha_Barrager(int client, float vecPos[3], float vecAng[3])
	{
		Barrack_Alt_Mecha_Barrager npc = view_as<Barrack_Alt_Mecha_Barrager>(BarrackBody(client, vecPos, vecAng, "100", "models/bots/soldier/bot_soldier.mdl", STEPTYPE_NORMAL,_,_,"models/pickups/pickup_powerup_precision.mdl"));
		
		i_NpcWeight[npc.index] = 1;
		
		func_NPCOnTakeDamage[npc.index] = BarrackBody_OnTakeDamage;
		func_NPCDeath[npc.index] = Barrack_Alt_Mecha_Barrager_NPCDeath;
		func_NPCThink[npc.index] = Barrack_Alt_Mecha_Barrager_ClotThink;

		npc.m_flSpeed = 175.0;
		fl_npc_basespeed = 175.0;
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_SECONDARY2");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		i_ammo_count[npc.index]=12;
		b_we_are_reloading[npc.index]=false;
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_drg_righteousbison/c_drg_righteousbison.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/soldier/soldier_officer.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/soldier/dec15_diplomat/dec15_diplomat.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		
		SetEntityRenderColor(npc.index, 125, 100, 100, 255);
		
		SetEntityRenderColor(npc.m_iWearable2, 125, 100, 100, 255);
		
		SetEntityRenderColor(npc.m_iWearable3, 125, 100, 100, 255);
		
		int skin = 1;	//1=blue, 0=red
		SetVariantInt(1);	
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		
		AcceptEntityInput(npc.m_iWearable1, "Enable");
		
		return npc;
	}
}

public void Barrack_Alt_Mecha_Barrager_ClotThink(int iNPC)
{
	Barrack_Alt_Mecha_Barrager npc = view_as<Barrack_Alt_Mecha_Barrager>(iNPC);
	float GameTime = GetGameTime(iNPC);
	if(BarrackBody_ThinkStart(npc.index, GameTime))
	{
		BarrackBody_ThinkTarget(npc.index, true, GameTime);
		int PrimaryThreatIndex = npc.m_iTarget;
		if(i_ammo_count[npc.index]<=0 && !b_we_are_reloading[npc.index])	//the npc will prefer to fully reload the clip before attacking, unless the target is too close.
		{
			b_we_are_reloading[npc.index]=true;
		}
		if(b_we_are_reloading[npc.index] && npc.m_flReloadIn<GameTime)	//Reload IF. Target too close. Empty clip.
		{
			npc.AddGesture("ACT_MP_RELOAD_STAND_SECONDARY2");
			npc.m_flReloadIn = 1.5* npc.BonusFireRate + GameTime;
			i_ammo_count[npc.index]++;
			npc.PlayRangedReloadSound();
		}
		if(i_ammo_count[npc.index]>=12)	//npc will stop reloading once clip size is full.
		{
			b_we_are_reloading[npc.index]=false;
		}
		if(PrimaryThreatIndex > 0)
		{
			npc.PlayIdleAlertSound();
			float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
			
			if(b_we_are_reloading[npc.index])
			{
				
				int Enemy_I_See;

				npc.m_flSpeed = fl_npc_basespeed;
				
				Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
				//Target close enough to hit
				if(IsValidEnemy(npc.index, Enemy_I_See)) //Check if i can even see.
				{
					BarrackBody_ThinkMove(npc.index, fl_npc_basespeed*0.5, "ACT_MP_RUN_SECONDARY2", "ACT_MP_RUN_SECONDARY2", 999999.0, _, false);
				}
			}
			else if(flDistanceToTarget < 90000 && !b_we_are_reloading[npc.index])
			{
				BarrackBody_ThinkMove(npc.index, fl_npc_basespeed, "ACT_MP_RUN_SECONDARY2", "ACT_MP_RUN_SECONDARY2", 700000.0, _, false);
				//Look at target so we hit.
			//	npc.FaceTowards(vecTarget, 1000.0);
				//Can we attack right now?
				int Enemy_I_See;		
				Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
				if(IsValidEnemy(npc.index, Enemy_I_See))
				{
					if(npc.m_flNextMeleeAttack < GameTime && i_ammo_count[npc.index] >0)
					{
						//Play attack anim
						npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY");
						PredictSubjectPositionForProjectiles(npc, PrimaryThreatIndex, 1100.0,_, vecTarget );
						npc.FaceTowards(vecTarget, 20000.0);
						npc.PlayRangedSound();
						npc.FireParticleRocket(vecTarget, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId),110.0, 1) ,  1200.0, 200.0 , "raygun_projectile_blue", true , false, _, _,_, GetClientOfUserId(npc.OwnerUserId));
						npc.m_flNextMeleeAttack = GameTime + 0.6* npc.BonusFireRate;
						npc.m_flReloadIn = GameTime + 2.75* npc.BonusFireRate;
						i_ammo_count[npc.index]--;
					}
				}
			}
			else
			{
				BarrackBody_ThinkMove(npc.index, 200.0, "ACT_MP_RUN_SECONDARY2", "ACT_MP_RUN_SECONDARY2", 80000.0, _, false);
			}
		}
		else
		{
			BarrackBody_ThinkMove(npc.index, 200.0, "ACT_MP_RUN_SECONDARY2", "ACT_MP_RUN_SECONDARY2", 80000.0, _, false);
			npc.PlayIdleSound();
		}
		if(!b_we_are_reloading[npc.index])
		{
			if(npc.m_flNextMeleeAttack > GameTime)
			{
				npc.m_flSpeed = 10.0;
			}
			else
			{
				npc.m_flSpeed = fl_npc_basespeed;
			}
		}
	}
	
	
}

void Barrack_Alt_Mecha_Barrager_NPCDeath(int entity)
{
	Barrack_Alt_Mecha_Barrager npc = view_as<Barrack_Alt_Mecha_Barrager>(entity);
	BarrackBody_NPCDeath(npc.index);
}
