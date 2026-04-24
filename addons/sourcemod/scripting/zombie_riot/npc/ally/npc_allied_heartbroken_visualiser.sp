#pragma semicolon 1
#pragma newdecls required


static char g_InitiateSound[][] = {
	"misc/halloween/spell_bat_cast.wav",
};
static char g_InitiateSoundParry[][] = {
	"weapons/draw_sword.wav",
};
static char g_ParryHit[][] = {
	"ambient/rottenburg/portcullis_slam.wav",
};

void AlliedHeartbrokenVisualiserAbility_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_InitiateSound));   i++) { PrecacheSound(g_InitiateSound[i]);   }
	for (int i = 0; i < (sizeof(g_InitiateSoundParry));   i++) { PrecacheSound(g_InitiateSoundParry[i]);   }
	for (int i = 0; i < (sizeof(g_ParryHit));   i++) { PrecacheSound(g_ParryHit[i]);   }
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "nothing");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_allied_heartbroken_visualiser");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPC_Add(data);
}

		
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return AlliedHeartbrokenVisualiserAbility(client, vecPos, vecAng, ally, data);
}
methodmap AlliedHeartbrokenVisualiserAbility < CClotBody
{
	//Incode defines which animation or action is used
	public void PlayInitSound() 
	{
		switch(this.m_iActionWhich)
		{
			case 1:
				EmitSoundToAll(g_InitiateSound[GetRandomInt(0, sizeof(g_InitiateSound) - 1)], this.index, SNDCHAN_STATIC, 80, _, 1.0, 80);
			case 2:
				EmitSoundToAll(g_InitiateSoundParry[GetRandomInt(0, sizeof(g_InitiateSoundParry) - 1)], this.index, SNDCHAN_STATIC, 80, _, 1.0, 70, .soundtime = GetGameTime() - 0.15);
		}
	}
	public void PlayParrySound() 
	{
		EmitSoundToAll(g_ParryHit[GetRandomInt(0, sizeof(g_ParryHit) - 1)], this.index, SNDCHAN_STATIC, 80, _, 1.0, 110);
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
	property float m_flAbilityDo
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float f_DamageDo
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	property float f_SpeedAcelerateAnim
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
	public AlliedHeartbrokenVisualiserAbility(int client, float vecPos[3], float vecAng[3], int enemyattach, const char[] data)
	{
		//The model seen here entirely depends on what action we want to do.
		char ModelUse[256];
		int WhichStateUse = -1;
		//What type
		if(!StrContains(data, "memorial_possession"))
		{
			WhichStateUse = 1;
			ModelUse = "models/player/demo.mdl";
		}
		if(!StrContains(data, "o_dohhulan_parry"))
		{

			WhichStateUse = 2;
			ModelUse = "models/player/demo.mdl";
		}

		if(!ModelUse[0])
		{
			PrintToChatAll("failed AlliedHeartbrokenVisualiserAbility Gen, Data:[%s]",data);
		}

		AlliedHeartbrokenVisualiserAbility npc = view_as<AlliedHeartbrokenVisualiserAbility>(CClotBody(vecPos, vecAng, ModelUse, "1.0", "100", TFTeam_Red, true));
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
		int CoffinEntity = CreateEntityByName("prop_dynamic_override");
		if(IsValidEntity(CoffinEntity))
		{
			DispatchKeyValue(CoffinEntity, "model", "models/props_manor/coffin_02.mdl");
			DispatchKeyValue(CoffinEntity, "solid", "0");
			SetEntityCollisionGroup(CoffinEntity, 24); //our savior
			SetEntPropEnt(CoffinEntity, Prop_Send, "m_hOwnerEntity", npc.index);			
			DispatchSpawn(CoffinEntity);

			SetEntProp(CoffinEntity, Prop_Send, "m_fEffects", EF_PARENT_ANIMATES| EF_NOSHADOW);
			
			SetParent(npc.index, CoffinEntity, "flag",_);
			SDKCall_SetLocalAngles(CoffinEntity, {0.0,90.0,0.0});
			SetEntPropFloat(CoffinEntity, Prop_Send, "m_flModelScale", 0.5);
			npc.m_iWearable8 = CoffinEntity;
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
		func_NPCDeath[npc.index] = AlliedHeartbrokenVisualiserAbility_NPCDeath;
		func_NPCThink[npc.index] = AlliedHeartbrokenVisaluser_ClotThink;
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
		npc.f_SpeedAcelerateAnim = 1.0;
		switch(npc.m_iActionWhich)
		{
			case 1:
			{
				npc.AddActivityViaSequence("selectionmenu_startpose");
				npc.SetCycle(0.0);
				npc.SetPlaybackRate(0.0);
				int Layer = npc.AddGestureViaSequence("Melee_Crouch_Swing");
				npc.SetLayerCycle(Layer, 0.347);
				npc.SetLayerPlaybackRate(Layer, 0.0);

				npc.m_flTimeUntillDone = GetGameTime() + (1.25 * npc.f_SpeedAcelerateAnim);

			}
			case 2:
			{
				npc.AddActivityViaSequence("taunt_forehead_slice");
				npc.SetCycle(0.198);
				npc.SetPlaybackRate(1.5);

				npc.m_flTimeUntillDone = GetGameTime() + (2.0);

			}
		}
		npc.PlayInitSound();

		return npc;
	}
}

public void AlliedHeartbrokenVisaluser_ClotThink(int iNPC)
{
	AlliedHeartbrokenVisualiserAbility npc = view_as<AlliedHeartbrokenVisualiserAbility>(iNPC);

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
			if(npc.m_iActionWhich == 3)	
				ExtraDo = 1;
			LeperReturnToNormal(owner, npc.m_iWearable9, ExtraDo);
			CoffinToggleVisiblity(owner, true);
			RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
			return;
		}
	}

	switch(npc.m_iActionWhich)
	{
		case 1:
		{
			Heartbroken_MemorialPossesion(owner, npc, GameTime);
		}
		case 2:
		{
			Heartbroken_ParryDohhulan(owner, npc, GameTime);
		}
	}
}

void Heartbroken_ParryDohhulan(int owner, AlliedHeartbrokenVisualiserAbility npc, float GameTime)
{
	if(!npc.m_flTimeUntillDone)
		return;


	
	float TimeLeft = npc.m_flTimeUntillDone - GameTime;
	if(TimeLeft < (1.75 * npc.f_SpeedAcelerateAnim))
	{
		if(npc.m_iChanged_WalkCycle != 2 && npc.m_iChanged_WalkCycle != 3)
		{
			ApplyStatusEffect(owner, owner, "HB In Parry", 1.75);
			npc.m_iChanged_WalkCycle = 2;
			npc.SetPlaybackRate(0.0);
		}
	}

	if(npc.m_iChanged_WalkCycle == 2 && HasSpecificBuff(owner, "HB Parried"))
	{
		RemoveSpecificBuff(owner, "HB Parried");
		npc.m_iChanged_WalkCycle = 3;
		npc.SetPlaybackRate(1.25);
		npc.SetCycle(0.49);
		npc.m_flTimeUntillDone = GameTime + 0.5;
		npc.PlayParrySound();
		npc.DispatchParticleEffect(npc.index, "mvm_soldier_shockwave", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("effect_hand_r"), PATTACH_POINT_FOLLOW, true);
		//we did a parry?
	}
}
void Heartbroken_MemorialPossesion(int owner, AlliedHeartbrokenVisualiserAbility npc, float GameTime)
{
	if(!npc.m_flTimeUntillDone)
		return;

	if(npc.m_flAbilityDo < GameTime)
	{
		Heartbroken_ShootHorseProjectile(owner,npc.m_iTarget, 0.75);
		npc.m_flAbilityDo = GameTime + 0.15;
	}
	/*
	float TimeLeft = npc.m_flTimeUntillDone - GameTime;
	if(TimeLeft < (1.25 * npc.f_SpeedAcelerateAnim))
	{
		if(npc.m_iChanged_WalkCycle != 3)
		{
			npc.m_iChanged_WalkCycle = 3;
			if(IsValidEnemy(owner, npc.m_iTarget))
			{
			//	npc.PlayHitSound();
			}
		}
	}
	else if(TimeLeft < (1.75 * npc.f_SpeedAcelerateAnim))
	{
		if(npc.m_iChanged_WalkCycle != 2)
		{
			npc.m_iChanged_WalkCycle = 2;
			
			//npc.AddActivityViaSequence("taunt_yetipunch");
			//npc.SetCycle(0.60);
			//npc.SetPlaybackRate(1.0 * (1.0 / npc.f_SpeedAcelerateAnim));
			//npc.m_iAttachmentWhichDo = -1;
			
		}
	}
	*/
}

public void AlliedHeartbrokenVisualiserAbility_NPCDeath(int entity)
{
	AlliedHeartbrokenVisualiserAbility npc = view_as<AlliedHeartbrokenVisualiserAbility>(entity);

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