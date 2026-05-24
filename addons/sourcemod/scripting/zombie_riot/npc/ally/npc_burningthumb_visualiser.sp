#pragma semicolon 1
#pragma newdecls required


static char g_InitiateSound[][] = {
	"items/powerup_pickup_base.wav",
};
static char g_ReloadSoundPlay[][] = {
	"weapons/flaregun_worldreload.wav",
};

void BurningThumbVisualiserAbility_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_InitiateSound));   i++) { PrecacheSound(g_InitiateSound[i]);   }
	for (int i = 0; i < (sizeof(g_ReloadSoundPlay));   i++) { PrecacheSound(g_ReloadSoundPlay[i]);   }
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "nothing");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_burningthumb_visualiser");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPC_Add(data);
}

		
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return BurningThumbVisualiserAbility(client, vecPos, vecAng, ally, data);
}
methodmap BurningThumbVisualiserAbility < CClotBody
{
	//Incode defines which animation or action is used
	public void PlayInitSound() 
	{
		EmitSoundToAll(g_InitiateSound[GetRandomInt(0, sizeof(g_InitiateSound) - 1)], this.index, SNDCHAN_STATIC, 80, _, 1.0, 90, .soundtime = GetGameTime() - 1.0);
		EmitSoundToAll(g_InitiateSound[GetRandomInt(0, sizeof(g_InitiateSound) - 1)], this.index, SNDCHAN_STATIC, 80, _, 1.0, 90, .soundtime = GetGameTime() - 1.0);
	}
	public void PlayReloadSound() 
	{
		EmitSoundToAll(g_ReloadSoundPlay[GetRandomInt(0, sizeof(g_ReloadSoundPlay) - 1)], this.index, SNDCHAN_STATIC, 80, _, 1.0, 80);
		EmitSoundToAll(g_ReloadSoundPlay[GetRandomInt(0, sizeof(g_ReloadSoundPlay) - 1)], this.index, SNDCHAN_STATIC, 80, _, 1.0, 80);
	}

	property int m_iActionWhich
	{
		public get()							{ return i_OverlordComboAttack[this.index]; }
		public set(int TempValueForProperty) 	{ i_OverlordComboAttack[this.index] = TempValueForProperty; }
	}

	property float m_flTimeUntillDone
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flReloadPlay
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flFreezeAnim
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}

	property int m_iWearablePlayerModel
	{
		public get()		 
		{ 
			return EntRefToEntIndex(i_MedkitAnnoyance[this.index]); 
		}
		public set(int iInt) 
		{
			if(iInt == -1)
			{
				i_MedkitAnnoyance[this.index] = INVALID_ENT_REFERENCE;
			}
			else
			{
				i_MedkitAnnoyance[this.index] = EntIndexToEntRef(iInt);
			}
		}
	}

	//ally in this case is used to see which enemy should be attached to the kill animation!
	public BurningThumbVisualiserAbility(int client, float vecPos[3], float vecAng[3], int enemyattach, const char[] data)
	{
		//The model seen here entirely depends on what action we want to do.
		char ModelUse[256];
		int WhichStateUse = -1;
		//What type
		if(!StrContains(data, "burning_reload"))
		{
			WhichStateUse = 1;
			ModelUse = "models/player/demo.mdl";
		}

		if(!ModelUse[0])
		{
			PrintToChatAll("failed BurningThumbVisualiserAbility Gen, Data:[%s]",data);
		}

		BurningThumbVisualiserAbility npc = view_as<BurningThumbVisualiserAbility>(CClotBody(vecPos, vecAng, ModelUse, "1.0", "100", TFTeam_Red, true));
		npc.m_iActionWhich = -1;
		
		i_NpcWeight[npc.index] = 999;
		SetEntPropEnt(npc.index,   Prop_Send, "m_hOwnerEntity", client);
		
		int ModelIndex;
		char ModelPath[255];
		int entity, i;
		if((i_CustomModelOverrideIndex[client] < BARNEY || !b_HideCosmeticsPlayer[client]))
		{
			SetEntityRenderMode(npc.index, RENDER_TRANSALPHA);
			SetEntityRenderColor(npc.index, 0, 0, 0, 0);
		}
		else
		{
			SetEntityRenderMode(npc.index, RENDER_TRANSALPHA);
			SetEntityRenderColor(npc.index, 255, 255, 255, 255);
		}


		SetVariantInt(GetEntProp(client, Prop_Send, "m_nBody"));
		AcceptEntityInput(npc.index, "SetBodyGroup");

		while(TF2U_GetWearable(client, entity, i, "tf_wearable"))
		{
			if(i_WeaponVMTExtraSetting[entity] != -1)
				continue;

			if(EntRefToEntIndex(i_Viewmodel_PlayerModel[client]) != entity || (i_CustomModelOverrideIndex[client] < BARNEY || !b_HideCosmeticsPlayer[client]))
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
			}
			if(!ModelPath[0])
				continue;

			for(int Repeat=0; Repeat<6; Repeat++)
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
							npc.m_iWearablePlayerModel = WearablePostIndex;
						}
						SetEntityRenderColor(WearablePostIndex, 255, 255, 255, 255);
						i_Wearable[npc.index][Repeat] = EntIndexToEntRef(WearablePostIndex);
					}
					break;
				}
			}
		}
		npc.m_bisWalking = false;
		npc.m_bDissapearOnDeath = true;
		b_NoKnockbackFromSources[npc.index] = true;
		npc.m_bNoKillFeed = true;
		npc.m_iBleedType = 0;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;
		b_ThisNpcIsImmuneToNuke[npc.index] = true;
		b_NpcIsInvulnerable[npc.index] = true;
		ApplyStatusEffect(npc.index, npc.index, "Clear Head", 999999.0);	
		func_NPCDeath[npc.index] = BurningThumbVisualiserAbility_NPCDeath;
		func_NPCThink[npc.index] = BurningThumbVisaluser_ClotThink;
		npc.m_iState = 0;
		npc.m_flSpeed = 0.0;
		npc.m_flMeleeArmor = 1.0;
		npc.m_flRangedArmor = 1.0;
		npc.m_iTarget = enemyattach;

		npc.StopPathing();
		b_DoNotUnStuck[npc.index] = true;
		b_NoGravity[npc.index] = true;
		b_ThisNpcIsImmuneToNuke[npc.index] = true;
		MakeObjectIntangeable(npc.index);
		if(IsValidEntity(npc.m_iTeamGlow))
			RemoveEntity(npc.m_iTeamGlow);

		npc.m_iActionWhich = WhichStateUse;
		switch(npc.m_iActionWhich)
		{
			case 1:
			{
				npc.AddActivityViaSequence("selectionmenu_anim01");
				npc.SetCycle(0.0);
				npc.SetPlaybackRate(1.0);

				npc.m_flTimeUntillDone = GetGameTime() + (2.3);
				npc.m_flReloadPlay = GetGameTime() + (0.85);
				npc.m_flFreezeAnim = GetGameTime() + (1.4);

			}
		}
		npc.PlayInitSound();

		return npc;
	}
}

public void BurningThumbVisaluser_ClotThink(int iNPC)
{
	BurningThumbVisualiserAbility npc = view_as<BurningThumbVisualiserAbility>(iNPC);

	float GameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > GameTime)
		return;
	
	int owner = GetEntPropEnt(npc.index, Prop_Data, "m_hOwnerEntity");
	npc.m_flNextDelayTime = GameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(npc.m_flTimeUntillDone)
	{
		if(npc.m_flTimeUntillDone < GetGameTime())
		{
			int ExtraDo = 0;
			LeperReturnToNormal(owner, npc.m_iWearable9, ExtraDo);
			RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
			return;
		}
	}
	if(npc.m_flReloadPlay)
	{
		if(npc.m_flReloadPlay < GetGameTime())
		{
			npc.PlayReloadSound();
			npc.m_flReloadPlay = 0.0;
		}
	}
	if(npc.m_flFreezeAnim)
	{
		if(npc.m_flFreezeAnim < GetGameTime())
		{
			npc.SetPlaybackRate(0.15);
			/*
			int Layer = npc.AddGestureViaSequence("gesture_MELEE_positive");
			npc.SetLayerCycle(Layer, 0.0); 
			npc.SetLayerPlaybackRate(Layer, 0.75);
			npc.m_flFreezeAnim = 0.0;
			*/
		}
	}
}
public void BurningThumbVisualiserAbility_NPCDeath(int entity)
{
	BurningThumbVisualiserAbility npc = view_as<BurningThumbVisualiserAbility>(entity);

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

	if(IsValidEntity(npc.m_iWearable8))
		RemoveEntity(npc.m_iWearable8);

	if(IsValidEntity(npc.m_iWearable9))
		RemoveEntity(npc.m_iWearable9);
}