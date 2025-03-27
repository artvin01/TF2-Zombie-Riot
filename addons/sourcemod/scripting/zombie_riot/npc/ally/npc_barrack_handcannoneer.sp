#pragma semicolon 1
#pragma newdecls required

// Balanced around Contruction Expert
// Construction Expert

static const char g_RangedAttackSounds[][] = {
	"weapons/quake_rpg_fire_remastered.wav",
};

public void BarrackHandCannoneerOnMapStart()
{
	PrecacheSoundArray(g_RangedAttackSounds);
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Hand Cannoneer");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_barrack_handcannoneer");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	NPC_Add(data);
}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return BarrackHandCannoneer(client, vecPos, vecAng, ally);
}

methodmap BarrackHandCannoneer < BarrackBody
{
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		

	}
	public BarrackHandCannoneer(int client, float vecPos[3], float vecAng[3], int ally)
	{
		BarrackHandCannoneer npc = view_as<BarrackHandCannoneer>(BarrackBody(client, vecPos, vecAng, "350",_,_,_,_,"models/pickups/pickup_powerup_precision.mdl"));
		
		i_NpcWeight[npc.index] = 1;
		KillFeed_SetKillIcon(npc.index, "revolver");
		
		func_NPCOnTakeDamage[npc.index] = BarrackBody_OnTakeDamage;
		func_NPCDeath[npc.index] = BarrackHandCannoneer_NPCDeath;
		func_NPCThink[npc.index] = BarrackHandCannoneer_ClotThink;
		func_NPCAnimEvent[npc.index] = BarrackHandCannoneer_HandleAnimEvent;
	
		npc.m_flSpeed = 175.0;
		
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/workshop_partner/weapons/c_models/c_bet_rocketlauncher/c_bet_rocketlauncher.mdl");
		SetVariantString("0.8");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("partyhat", "models/workshop/player/items/spy/short2014_deadhead/short2014_deadhead.mdl");
		SetVariantString("2.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		SetVariantInt(1);
		AcceptEntityInput(npc.m_iWearable1, "SetBodyGroup");
		
		return npc;
	}
}

public void BarrackHandCannoneer_ClotThink(int iNPC)
{
	BarrackHandCannoneer npc = view_as<BarrackHandCannoneer>(iNPC);
	float GameTime = GetGameTime(iNPC);
	if(BarrackBody_ThinkStart(npc.index, GameTime))
	{
		BarrackBody_ThinkTarget(npc.index, true, GameTime);

		if(npc.m_iTarget > 0)
		{
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);

			if(flDistanceToTarget < 160000.0)
			{
				int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				//Target close enough to hit
				if(IsValidEnemy(npc.index, Enemy_I_See))
				{
					//Can we attack right now?
					if(npc.m_flNextMeleeAttack < GameTime)
					{
						npc.m_flSpeed = 0.0;
						npc.FaceTowards(vecTarget, 30000.0);
						//Play attack anim
						npc.AddGesture("ACT_CUSTOM_ATTACK_CANNONEER");
						
			//			npc.PlayRangedSound();
			//			npc.FireArrow(vecTarget, 25.0, 1200.0);
						npc.m_flNextMeleeAttack = GameTime + (5.0 * npc.BonusFireRate);
						npc.m_flReloadDelay = GameTime + (0.7 * npc.BonusFireRate);
					}
				}
			}
		}

		BarrackBody_ThinkMove(npc.index, 175.0, "ACT_CUSTOM_IDLE_CROSSBOW", "ACT_CUSTOM_WALK_GUN", 145000.0);
	}
}

void BarrackHandCannoneer_HandleAnimEvent(int entity, int event)
{
	if(event == 1001)
	{
		BarrackHandCannoneer npc = view_as<BarrackHandCannoneer>(entity);
		
		if(IsValidEnemy(npc.index, npc.m_iTarget))
		{
			float vecTarget[3]; PredictSubjectPositionForProjectiles(npc, npc.m_iTarget, 1200.0,_, vecTarget);
			npc.FaceTowards(vecTarget, 30000.0);
			
			npc.PlayRangedSound();
			npc.FireArrow(vecTarget, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId),5500.0, 1), 1200.0, _, _, _, GetClientOfUserId(npc.OwnerUserId));
		}
	}
}

void BarrackHandCannoneer_NPCDeath(int entity)
{
	BarrackHandCannoneer npc = view_as<BarrackHandCannoneer>(entity);
	BarrackBody_NPCDeath(npc.index);
	SDKUnhook(npc.index, SDKHook_Think, BarrackHandCannoneer_ClotThink);
}
