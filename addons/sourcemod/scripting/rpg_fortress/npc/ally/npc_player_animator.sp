#pragma semicolon 1
#pragma newdecls required



void PlayerAnimatorNPC_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Player Animator NPC");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_player_animator");
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return PlayerAnimatorNPC(client, vecPos, vecAng, ally, data);
}
methodmap PlayerAnimatorNPC < CClotBody
{
	
	public PlayerAnimatorNPC(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		int Type = StringToInt(data);
		PlayerAnimatorNPC npc;
		switch(Type)
		{
			case 1:
			{
				npc = view_as<PlayerAnimatorNPC>(CClotBody(vecPos, vecAng, "models/player/heavy.mdl", "1.0", "100", TFTeam_Red, true));
				npc.m_flNextRangedAttackHappening = GetGameTime() + 1.5;
				npc.m_flRangedSpecialDelay = GetGameTime() + 2.0;
			}
			case 2:
			{
				npc = view_as<PlayerAnimatorNPC>(CClotBody(vecPos, vecAng, "models/player/heavy.mdl", "1.0", "100", TFTeam_Red, true));
				npc.m_flNextRangedAttackHappening = GetGameTime() + 0.75;
				npc.m_flRangedSpecialDelay = GetGameTime() + 1.0;
			}
		}
		i_AttacksTillReload[npc.index] = Type;
		
		i_NpcWeight[npc.index] = 999;
		SetEntPropEnt(npc.index,   Prop_Send, "m_hOwnerEntity", client);
		
		int ModelIndex;
		char ModelPath[255];
		int entity, i;
			
		SetEntityRenderMode(npc.index, RENDER_TRANSALPHA);
		SetEntityRenderColor(npc.index, 0, 0, 0, 0);


		SetVariantInt(GetEntProp(client, Prop_Send, "m_nBody"));
		AcceptEntityInput(npc.index, "SetBodyGroup");

		while(TF2U_GetWearable(client, entity, i, "tf_wearable"))
		{
			if(i_WeaponVMTExtraSetting[entity] != -1)
				continue;

			ModelIndex = GetEntProp(entity, Prop_Data, "m_nModelIndex");
			if(ModelIndex < 0)
			{
				GetEntPropString(entity, Prop_Data, "m_ModelName", ModelPath, sizeof(ModelPath));
			}
			else
			{
				ModelIndexToString(ModelIndex, ModelPath, sizeof(ModelPath));
			}
			if(!ModelPath[0])
				continue;

			for(int Repeat=0; Repeat<7; Repeat++)
			{
				int WearableIndex = i_Wearable[npc.index][Repeat];
				if(!IsValidEntity(WearableIndex))
				{	
					int WearablePostIndex = npc.EquipItem("head", ModelPath);
					if(IsValidEntity(WearablePostIndex))
					{	
						if(entity == EntRefToEntIndex(i_Viewmodel_PlayerModel[client]))
						{
							SetVariantInt(GetEntProp(client, Prop_Send, "m_nBody"));
							AcceptEntityInput(WearablePostIndex, "SetBodyGroup");
						}
						SetEntityRenderColor(WearablePostIndex, 255, 255, 255, 255);
						i_Wearable[npc.index][Repeat] = EntIndexToEntRef(WearablePostIndex);
					}
					break;
				}
			}
		}

		npc.m_bDissapearOnDeath = true;
		b_NoKnockbackFromSources[npc.index] = true;
		npc.m_bNoKillFeed = true;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;
		npc.m_bisWalking = false;

		b_NpcIsInvulnerable[npc.index] = true;
		b_IgnorePlayerCollisionNPC[npc.index] = true;
		b_DoNotUnStuck[npc.index] = true;
		
		func_NPCDeath[npc.index] = PlayerAnimatorNPC_NPCDeath;
		func_NPCThink[npc.index] = PlayerAnimatorNPC_ClotThink;

		npc.m_iState = 0;
		npc.m_flSpeed = 0.0;
		npc.m_flAttackHappens = GetGameTime() + 0.03;
		npc.m_flAttackHappens_2 = GetGameTime() + 0.5;

		npc.m_flMeleeArmor = 1.0;
		npc.m_flRangedArmor = 1.0;

		npc.StopPathing();
		b_DoNotUnStuck[npc.index] = true;
		b_NoGravity[npc.index] = true;
		MakeObjectIntangeable(npc.index);
		if(IsValidEntity(npc.m_iTeamGlow))
			RemoveEntity(npc.m_iTeamGlow);

		return npc;
	}
}

public void PlayerAnimatorNPC_ClotThink(int iNPC)
{
	PlayerAnimatorNPC npc = view_as<PlayerAnimatorNPC>(iNPC);

	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
		return;
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;
	/*
		//start with taunt_soviet_showoff, frame 145/182
		//end with taunt_table_flip_outro, frame 18/117

	*/
	switch(i_AttacksTillReload[npc.index])
	{
		case 1:
		{
			if(npc.m_flNextRangedAttackHappening)
			{
				//dont suck them in if its the final bit
				if(npc.m_flNextRangedAttackHappening - 0.2 > GetGameTime(npc.index))
				{
					if(npc.m_iChanged_WalkCycle != 1)
					{
						npc.AddActivityViaSequence("taunt_soviet_showoff");
						//npc.AddGesture("ACT_MP_RUN_MELEE");
						npc.SetPlaybackRate(0.2);	
						npc.SetCycle(0.79);
						npc.m_iChanged_WalkCycle = 1;
					}

					Bing_BangVisualiser(npc.index, 150.0, 70.0, 350.0);
				}
				if(npc.m_flNextRangedAttackHappening < GetGameTime(npc.index))
				{
					if(npc.m_iChanged_WalkCycle != 2)
					{
						npc.AddActivityViaSequence("taunt_table_flip_outro");
						//npc.AddGesture("ACT_MP_RUN_MELEE");
						npc.SetPlaybackRate(0.2);	
						npc.SetCycle(0.15);
						npc.m_iChanged_WalkCycle = 2;
					}
					npc.m_flNextRangedAttackHappening = 0.0;
					//Big TE OR PARTICLE that explodes
					//Make it purple too
					BingBangExplosion(npc.index, npc.m_flNextMeleeAttack, 350.0, 150.0, 1.0);
				}
			}
		}
		case 2:
		{
			if(npc.m_flNextRangedAttackHappening)
			{
				//dont suck them in if its the final bit
				if(npc.m_flNextRangedAttackHappening - 0.1 > GetGameTime(npc.index))
				{
					if(npc.m_iChanged_WalkCycle != 1)
					{
						npc.AddActivityViaSequence("taunt_soviet_showoff");
						//npc.AddGesture("ACT_MP_RUN_MELEE");
						npc.SetPlaybackRate(0.4);	
						npc.SetCycle(0.79);
						npc.m_iChanged_WalkCycle = 1;
					}

					Bing_BangVisualiser(npc.index, 150.0, 70.0, 350.0);
				}
				if(npc.m_flNextRangedAttackHappening < GetGameTime(npc.index))
				{
					if(npc.m_iChanged_WalkCycle != 2)
					{
						npc.AddActivityViaSequence("taunt_table_flip_outro");
						//npc.AddGesture("ACT_MP_RUN_MELEE");
						npc.SetPlaybackRate(0.4);	
						npc.SetCycle(0.15);
						npc.m_iChanged_WalkCycle = 2;
					}
					npc.m_flNextRangedAttackHappening = 0.0;
					//Big TE OR PARTICLE that explodes
					//Make it purple too
					BingBangExplosion(npc.index, npc.m_flNextMeleeAttack, 350.0, 150.0, 1.0);
				}
			}
		}
	}

	if(npc.m_flRangedSpecialDelay)
	{
		if(npc.m_flRangedSpecialDelay < GetGameTime())
		{
			RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
		}
	}
}

public void PlayerAnimatorNPC_NPCDeath(int entity)
{
	PlayerAnimatorNPC npc = view_as<PlayerAnimatorNPC>(entity);

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
	
	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);

	if(IsValidEntity(npc.m_iWearable7))
		RemoveEntity(npc.m_iWearable7);
}