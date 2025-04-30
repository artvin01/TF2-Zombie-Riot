#pragma semicolon 1
#pragma newdecls required

static const char g_MeleeHitSounds[][] = {
	"weapons/metal_gloves_hit_flesh1.wav",
	"weapons/metal_gloves_hit_flesh2.wav",
	"weapons/metal_gloves_hit_flesh3.wav",
	"weapons/metal_gloves_hit_flesh4.wav",
};

static const char g_IdleSounds[][] = {
	"vo/mvm/norm/heavy_mvm_jeers03.mp3",	
	"vo/mvm/norm/heavy_mvm_jeers04.mp3",	
	"vo/mvm/norm/heavy_mvm_jeers06.mp3",
	"vo/mvm/norm/heavy_mvm_jeers09.mp3",	
};

static const char g_IdleAlertedSounds[][] = {
	"vo/mvm/norm/heavy_mvm_meleedare04.mp3",
	"vo/mvm/norm/heavy_mvm_revenge14.mp3",
	"vo/mvm/norm/heavy_mvm_meleedare12.mp3",
};
static const char g_DeathSounds[][] =
{
	"vo/mvm/norm/heavy_mvm_paincrticialdeath01.mp3",
	"vo/mvm/norm/heavy_mvm_paincrticialdeath02.mp3",
	"vo/mvm/norm/heavy_mvm_paincrticialdeath03.mp3",
};


public void Barrack_Alt_Mecha_Loader_MapStart()
{
	PrecacheModel("models/bots/heavy/bot_heavy.mdl");
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Barracks Mecha Loader");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_barrack_alt_mecha_loader");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return Barrack_Alt_Mecha_Loader(client, vecPos, vecAng);
}

methodmap Barrack_Alt_Mecha_Loader < BarrackBody
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
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds	) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		

	}
	public void PlayNPCDeath() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		

	}
	public Barrack_Alt_Mecha_Loader(int client, float vecPos[3], float vecAng[3])
	{
		Barrack_Alt_Mecha_Loader npc = view_as<Barrack_Alt_Mecha_Loader>(BarrackBody(client, vecPos, vecAng, "500", "models/bots/heavy/bot_heavy.mdl", STEPTYPE_NORMAL,_,_,"models/pickups/pickup_powerup_strength_arm.mdl"));
		
		
		i_NpcWeight[npc.index] = 1;
		
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_flAttackHappens_bullshit = 0.0;
		
		func_NPCOnTakeDamage[npc.index] = BarrackBody_OnTakeDamage;
		func_NPCDeath[npc.index] = Barrack_Alt_Mecha_Loader_NPCDeath;
		func_NPCThink[npc.index] = Barrack_Alt_Mecha_Loader_ClotThink;

		npc.m_flSpeed = 225.0;
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/player/items/heavy/heavy_wolf_helm.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		
		int skin = 1;	//1=blue, 0=red
		SetVariantInt(1);	
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		
		// AcceptEntityInput(npc.m_iWearable1, "Enable");
		
		return npc;
	}
}

public void Barrack_Alt_Mecha_Loader_ClotThink(int iNPC)
{
	Barrack_Alt_Mecha_Loader npc = view_as<Barrack_Alt_Mecha_Loader>(iNPC);
	float GameTime = GetGameTime(iNPC);
	
	if(BarrackBody_ThinkStart(npc.index, GameTime))
	{
		int client = BarrackBody_ThinkTarget(npc.index, true, GameTime);

		if(npc.m_iTarget > 0)
		{
			npc.PlayIdleAlertSound();
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
			
			//Target close enough to hit
			if(flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED || npc.m_flAttackHappenswillhappen)
			{
				if(npc.m_flNextMeleeAttack < GameTime || npc.m_flAttackHappenswillhappen)
				{
					float Health = float(GetEntProp(npc.index, Prop_Data, "m_iHealth"));
					float MaxHealth = float(ReturnEntityMaxHealth(npc.index));
					
					float damage = 2000.0;
					float speed = (0.25*npc.BonusFireRate) * (Health / MaxHealth)+ 0.3;
					
					if (!npc.m_flAttackHappenswillhappen)
					{
						npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
						npc.m_flAttackHappens = GameTime + speed;
						npc.m_flAttackHappens_bullshit = GameTime + (speed + 0.1);
						npc.m_flNextMeleeAttack = GameTime + speed;
						npc.m_flAttackHappenswillhappen = true;
					}
						
					if(npc.m_flAttackHappens < GameTime && npc.m_flAttackHappens_bullshit >= GameTime && npc.m_flAttackHappenswillhappen)
					{
						Handle swingTrace;
						npc.FaceTowards(vecTarget, 20000.0);
						if(npc.DoSwingTrace(swingTrace, npc.m_iTarget))
						{
							int target = TR_GetEntityIndex(swingTrace);	
							
							float vecHit[3];
							TR_GetEndPosition(vecHit, swingTrace);
							
							if(target > 0) 
							{
								SDKHooks_TakeDamage(target, npc.index, client, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId),damage, 0), DMG_CLUB, -1, _, vecHit);
								npc.PlayMeleeSound();
							}
						}
						delete swingTrace;
						npc.m_flAttackHappenswillhappen = false;
					}
					else if(npc.m_flAttackHappens_bullshit < GameTime && npc.m_flAttackHappenswillhappen)
					{
						npc.m_flAttackHappenswillhappen = false;
					}
				}
			}
		}
		else
		{
			npc.PlayIdleSound();
		}
		BarrackBody_ThinkMove(npc.index, 250.0, "ACT_MP_RUN_MELEE", "ACT_MP_RUN_MELEE");
	}
}

void Barrack_Alt_Mecha_Loader_NPCDeath(int entity)
{	
	Barrack_Alt_Mecha_Loader npc = view_as<Barrack_Alt_Mecha_Loader>(entity);
	
	float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);
	Explode_Logic_Custom(Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId),2250.0, 1), GetClientOfUserId(npc.OwnerUserId), npc.index, -1, vecMe, 200*2.0 ,_,0.8, false); // Heavy goes boom on death
	
	BarrackBody_NPCDeath(npc.index);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
		
	npc.PlayNPCDeath();

}