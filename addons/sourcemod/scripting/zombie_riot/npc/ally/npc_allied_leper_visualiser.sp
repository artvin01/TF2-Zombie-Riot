#pragma semicolon 1
#pragma newdecls required



void AlliedLeperVisualiserAbility_OnMapStart_NPC()
{
	PrecacheModel("models/weapons/c_models/c_claymore/c_claymore.mdl");
}

methodmap AlliedLeperVisualiserAbility < CClotBody
{
	
	public AlliedLeperVisualiserAbility(int client, float vecPos[3], float vecAng[3], bool ally, const char[] data)
	{
		AlliedLeperVisualiserAbility npc = view_as<AlliedLeperVisualiserAbility>(CClotBody(vecPos, vecAng, "models/player/demo.mdl", "1.0", "100", true, true));
		
		i_NpcInternalId[npc.index] = WEAPON_LEPER_AFTERIMAGE;
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
						SetEntityRenderMode(WearablePostIndex, RENDER_TRANSCOLOR); //Make it half invis.
						SetEntityRenderColor(WearablePostIndex, 255, 255, 255, 255);
						i_Wearable[npc.index][Repeat] = EntIndexToEntRef(WearablePostIndex);
					}
					break;
				}
			}
		}
		bool solemny = StrContains(data, "solemny") != -1;
		bool hew = StrContains(data, "hew") != -1;
		
		if(hew)
		{
			npc.SetActivity("ACT_MP_RUN_ITEM1");
			npc.AddGesture("ACT_MP_ATTACK_STAND_ITEM1");
			int layerCount = CBaseAnimatingOverlay(npc.index).GetNumAnimOverlays();
			for(int ilayeri; ilayeri < layerCount; ilayeri++)
			{
				view_as<CClotBody>(npc.index).SetLayerPlaybackRate(ilayeri, 0.05);
				view_as<CClotBody>(npc.index).SetLayerCycle(ilayeri, 0.6);
			}
		}
		if(solemny)
		{
			
			npc.AddActivityViaSequence("selectionmenu_anim01");
			npc.SetPlaybackRate(0.01);
			npc.SetCycle(0.01);
			if(IsValidEntity(npc.m_iWearable7))
				RemoveEntity(npc.m_iWearable7);

			npc.m_iWearable7 = npc.EquipItemSeperate("head", "models/effects/vol_light256x512.mdl",_,_,_,250.0);

			if(IsValidEntity(npc.m_iWearable6))
				RemoveEntity(npc.m_iWearable6);

			float flPos[3]; // original
			float flAng[3]; // original
			npc.GetAttachment("head", flPos, flAng);
			npc.m_iWearable6 = ParticleEffectAt_Parent(flPos, "utaunt_leaftaunt_fallingleaves", npc.index, "head", {0.0,0.0,-50.0});

			
			SetEntityRenderMode(npc.m_iWearable7, RENDER_TRANSALPHA);
			SetEntityRenderColor(npc.m_iWearable7, 255, 165, 0, 255);

		}

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_bDissapearOnDeath = true;
		b_NoKnockbackFromSources[npc.index] = true;
		npc.m_bNoKillFeed = true;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;

		b_ThisNpcIsImmuneToNuke[npc.index] = true;
		b_NpcIsInvulnerable[npc.index] = true;
		
		SDKHook(npc.index, SDKHook_Think, AlliedLeperVisaluser_ClotThink);

		npc.m_iState = 0;
		npc.m_flSpeed = 0.0;
		npc.m_flAttackHappens = GetGameTime() + 0.03;
		npc.m_flAttackHappens_2 = GetGameTime() + 0.5;
		npc.m_flRangedSpecialDelay = GetGameTime() + 2.0;

		npc.m_flMeleeArmor = 1.0;
		npc.m_flRangedArmor = 1.0;

		NPC_StopPathing(npc.index);
		b_DoNotUnStuck[npc.index] = true;
		b_NoGravity[npc.index] = true;
		SetEntityCollisionGroup(npc.index, 1); //Dont Touch Anything.
		SetEntProp(npc.index, Prop_Send, "m_usSolidFlags", 12); 
		SetEntProp(npc.index, Prop_Data, "m_nSolidType", 6); 
		if(IsValidEntity(npc.m_iTeamGlow))
			RemoveEntity(npc.m_iTeamGlow);

		return npc;
	}
}

public void AlliedLeperVisaluser_ClotThink(int iNPC)
{
	AlliedLeperVisualiserAbility npc = view_as<AlliedLeperVisualiserAbility>(iNPC);

	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
		return;
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	switch(i_AttacksTillReload[npc.index])
	{
		case 0:
		{
			if(npc.m_flAttackHappens)
			{
				if(npc.m_flAttackHappens < GetGameTime())
				{
					npc.m_flAttackHappens = 0.0;
					npc.AddGesture("ACT_MP_ATTACK_STAND_ITEM1");
					int layerCount = CBaseAnimatingOverlay(npc.index).GetNumAnimOverlays();
					for(int i; i < layerCount; i++)
					{
						view_as<CClotBody>(npc.index).SetLayerPlaybackRate(i, 0.05);
						view_as<CClotBody>(npc.index).SetLayerCycle(i, 0.6);
					}
				}
			}
		}
		case 1:
		{
			if(npc.m_flAttackHappens)
			{
				if(npc.m_flAttackHappens < GetGameTime())
				{
					npc.m_flAttackHappens = 0.0;
					npc.AddActivityViaSequence("selectionmenu_anim01");
					npc.SetPlaybackRate(0.01);
					npc.SetCycle(0.01);
					if(IsValidEntity(npc.m_iWearable7))
						RemoveEntity(npc.m_iWearable7);

					npc.m_iWearable7 = npc.EquipItemSeperate("head", "models/effects/vol_light256x512.mdl",_,_,_,150.0);

					if(IsValidEntity(npc.m_iWearable6))
						RemoveEntity(npc.m_iWearable6);

						
					SetEntityRenderMode(npc.m_iWearable7, RENDER_TRANSALPHA);
					SetEntityRenderColor(npc.m_iWearable7, 255, 165, 0, 255);

					float flPos[3]; // original
					float flAng[3]; // original
					npc.GetAttachment("head", flPos, flAng);
					npc.m_iWearable6 = ParticleEffectAt_Parent(flPos, "utaunt_leaftaunt_fallingleaves", npc.index, "head", {0.0,0.0,-50.0});
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

public void AlliedLeperVisualiserAbility_NPCDeath(int entity)
{
	AlliedLeperVisualiserAbility npc = view_as<AlliedLeperVisualiserAbility>(entity);

	SDKUnhook(npc.index, SDKHook_Think, AlliedLeperVisaluser_ClotThink);
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