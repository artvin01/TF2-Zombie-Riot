#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	")physics/metal/metal_canister_impact_hard1.wav",
	")physics/metal/metal_canister_impact_hard2.wav",
	")physics/metal/metal_canister_impact_hard3.wav",
};

static const char g_HurtSounds[][] = {
	")physics/metal/metal_box_impact_bullet1.wav",
	")physics/metal/metal_box_impact_bullet2.wav",
	")physics/metal/metal_box_impact_bullet3.wav",
};

static const char g_IdleSounds[][] = {
	"npc/metropolice/vo/affirmative.wav",
	"npc/metropolice/vo/affirmative2.wav",
	"npc/metropolice/vo/canalblock.wav",
	"npc/metropolice/vo/chuckle.wav",
	"npc/metropolice/vo/citizen.wav",
	"npc/metropolice/vo/code7.wav",
	"npc/metropolice/vo/code100.wav",
	"npc/metropolice/vo/copy.wav",
	"npc/metropolice/vo/breakhiscover.wav",
	"npc/metropolice/vo/help.wav",
	"npc/metropolice/vo/hesgone148.wav",
	"npc/metropolice/vo/hesrunning.wav",
	"npc/metropolice/vo/infection.wav",
	"npc/metropolice/vo/king.wav",
	"npc/metropolice/vo/needanyhelpwiththisone.wav",

	"npc/metropolice/vo/pickupthecan2.wav",
	"npc/metropolice/vo/sociocide.wav",
	"npc/metropolice/vo/watchit.wav",
	"npc/metropolice/vo/xray.wav",
	"npc/metropolice/vo/youknockeditover.wav",
};

static const char g_IdleAlertedSounds[][] = {
	"npc/metropolice/vo/affirmative.wav",
	"npc/metropolice/vo/affirmative2.wav",
	"npc/metropolice/vo/canalblock.wav",
	"npc/metropolice/vo/chuckle.wav",
	"npc/metropolice/vo/citizen.wav",
	"npc/metropolice/vo/code7.wav",
	"npc/metropolice/vo/code100.wav",
	"npc/metropolice/vo/copy.wav",
	"npc/metropolice/vo/breakhiscover.wav",
	"npc/metropolice/vo/help.wav",
	"npc/metropolice/vo/hesgone148.wav",
	"npc/metropolice/vo/hesrunning.wav",
	"npc/metropolice/vo/infection.wav",
	"npc/metropolice/vo/king.wav",
	"npc/metropolice/vo/needanyhelpwiththisone.wav",
	"npc/metropolice/vo/pickupthecan1.wav",
	"npc/metropolice/vo/pickupthecan2.wav",
	"npc/metropolice/vo/pickupthecan3.wav",
	"npc/metropolice/vo/sociocide.wav",
	"npc/metropolice/vo/watchit.wav",
	"npc/metropolice/vo/xray.wav",
	"npc/metropolice/vo/youknockeditover.wav",
	"npc/metropolice/takedown.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/cleaver_hit_02.wav",
	"weapons/cleaver_hit_03.wav",
	"weapons/cleaver_hit_05.wav",
	"weapons/cleaver_hit_06.wav",
	"weapons/cleaver_hit_07.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/bow_shoot.wav",
};

static const char g_MeleeMissSounds[][] = {
	"weapons/draw_sword.wav",
};


void NearlSwordAbility_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	PrecacheModel("models/weapons/c_models/c_claymore/c_claymore.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Nearl Radiant Sword");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_nearl_sword");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3],int ally)
{
	return NearlSwordAbility(vecPos, vecAng, ally);
}

methodmap NearlSwordAbility < CClotBody
{
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);

	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
	}

	public void PlayMeleeMissSound() 
	{
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		
	}
	
	public NearlSwordAbility(float vecPos[3], float vecAng[3], int ally)
	{
		NearlSwordAbility npc = view_as<NearlSwordAbility>(CClotBody(vecPos, vecAng, "models/weapons/w_models/w_drg_ball.mdl", "1.0", "100", ally));
		
		i_NpcWeight[npc.index] = 999;
		
//		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
//		int iActivity = npc.LookupActivity("ACT_VILLAGER_RUN");
//		if(iActivity > 0) npc.StartActivity(iActivity);
		SetEntityRenderMode(npc.index, RENDER_GLOW); //cool gold.

		npc.m_iWearable1 = npc.EquipItemSeperate("models/workshop/weapons/c_models/c_claidheamohmor/c_claidheamohmor.mdl");
		SetVariantString("1.5");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		float eyePitch[3];
		eyePitch[0] = -185.0;
		eyePitch[1] = GetRandomFloat(-180.0,180.0);
		eyePitch[2] = 0.0;

		SetVariantColor(view_as<int>({255, 215, 0, 175}));
		AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");

		SetEntityRenderMode(npc.m_iWearable1, RENDER_GLOW); //cool gold.
		SetEntityRenderColor(npc.m_iWearable1, 255, 215, 0, 225);
		
		float fPos[3];
		GetEntPropVector(npc.m_iWearable1, Prop_Data, "m_vecOrigin", fPos);
		fPos[2] += 81.0;
		
		TeleportEntity(npc.m_iWearable1, fPos, eyePitch, NULL_VECTOR);

		npc.m_iWearable2 = npc.EquipItemSeperate("models/props_debris/concrete_debris128pile001a.mdl");
		SetVariantString("0.5");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		GetEntPropVector(npc.m_iWearable2, Prop_Data, "m_vecOrigin", fPos);
		fPos[2] += 5.0;
		
		SetEntityRenderMode(npc.m_iWearable2, RENDER_GLOW); //cool gold.
		SetEntityRenderColor(npc.m_iWearable2, 255, 255, 0, 225);
		
		TeleportEntity(npc.m_iWearable2, fPos, _, NULL_VECTOR);

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_bDissapearOnDeath = true;
		b_NoKnockbackFromSources[npc.index] = true;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;

	//	i_NpcIsABuilding[npc.index] = true;
		b_ThisNpcIsImmuneToNuke[npc.index] = true;

		
		func_NPCDeath[npc.index] = NearlSwordAbility_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = NearlSwordAbility_OnTakeDamage;
		func_NPCThink[npc.index] = NearlSwordAbility_ClotThink;

		npc.m_iState = 0;
		npc.m_flSpeed = 0.0;
		
		npc.m_flMeleeArmor = 1.0;
		npc.m_flRangedArmor = 1.25;

		npc.StopPathing();

		NearlSword_HealthHud(npc);
		b_DoNotUnStuck[npc.index] = true;

		return npc;
	}
}

public void NearlSwordAbility_ClotThink(int iNPC)
{
	NearlSwordAbility npc = view_as<NearlSwordAbility>(iNPC);

	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
		return;
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;

	if(npc.m_blPlayHurtAnimation)
	{
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	NearlSword_HealthHud(npc);
}


public int NearlSword_HealthHud(NearlSwordAbility npc)
{
	char HealthText[32];
	int HealthColour[4];
	int MaxHealth = ReturnEntityMaxHealth(npc.index);
	int Health = GetEntProp(npc.index, Prop_Data, "m_iHealth");
	for(int i=0; i<10; i++)
	{
		if(Health >= MaxHealth*(i*0.1))
		{
			Format(HealthText, sizeof(HealthText), "%s%s", HealthText, "|");
		}
		else
		{
			Format(HealthText, sizeof(HealthText), "%s%s", HealthText, ".");
		}
	}

	HealthColour[0] = 255;
	HealthColour[1] = 255;
	HealthColour[2] = 0;
	if(Health <= MaxHealth)
	{
		HealthColour[0] = Health * 255  / MaxHealth;
		HealthColour[1] = Health * 255  / MaxHealth;
		
		HealthColour[0] = 255 - HealthColour[0];
	}
	else
	{
		HealthColour[0] = 0;
		HealthColour[1] = 0;
		HealthColour[2] = 255;
	}	
	HealthColour[3] = 255;

	if(IsValidEntity(npc.m_iWearable6))
	{
		char sColor[32];
		Format(sColor, sizeof(sColor), " %d %d %d %d ", HealthColour[0], HealthColour[1], HealthColour[2], HealthColour[3]);
		DispatchKeyValue(npc.m_iWearable6,     "color", sColor);
		DispatchKeyValue(npc.m_iWearable6, "message", HealthText);
	}
	else
	{
		int TextEntity = SpawnFormattedWorldText(HealthText,{0.0,0.0,100.0}, 17, HealthColour, npc.index);
	//	SDKHook(TextEntity, SDKHook_SetTransmit, BarrackBody_Transmit);
		DispatchKeyValue(TextEntity, "font", "1");
		npc.m_iWearable6 = TextEntity;	
	}
	return npc.m_iWearable6;
}


public Action NearlSwordAbility_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	NearlSwordAbility npc = view_as<NearlSwordAbility>(victim);
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	if(b_thisNpcIsARaid[attacker])
	{
		damage *= 2.0; //takes 2x more dmg from raids itself.
	}
	return Plugin_Changed;
}

public void NearlSwordAbility_NPCDeath(int entity)
{
	NearlSwordAbility npc = view_as<NearlSwordAbility>(entity);
	npc.PlayDeathSound();	
	float pos[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
	makeexplosion(-1, pos, 0, 0);

	
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