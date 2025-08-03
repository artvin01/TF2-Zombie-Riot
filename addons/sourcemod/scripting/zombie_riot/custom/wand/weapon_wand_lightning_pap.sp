#pragma semicolon 1
#pragma newdecls required

static float ability_cooldown[MAXPLAYERS+1]={0.0, ...};
static float Smite_Damage[MAXPLAYERS+1]={0.0, ...};
static float Damage_Reduction[MAXPLAYERS+1]={0.0, ...};
static int Smite_Cost = 250;
static float Smite_BaseDMG = 200.0;
static float Smite_DMGMult = 7.5;
static float Smite_ChargeTime = 0.99;
static float Smite_ChargeSpan = 0.33;
static float Smite_Radius = 400.0;

#define SOUND_WAND_LIGHTNING_ABILITY_PAP_CHARGE "weapons/vaccinator_charge_tier_03.wav"

void Wand_LightningPap_Map_Precache()
{
	PrecacheSound(SOUND_WAND_LIGHTNING_ABILITY_PAP_INTRO);
	PrecacheSound(SOUND_WAND_LIGHTNING_ABILITY_PAP_CHARGE);
	PrecacheSound(SOUND_WAND_LIGHTNING_ABILITY_PAP_SMITE);
}

public void Lighting_Wand_Pap_ClearAll()
{
	Zero(ability_cooldown);
}

public void Weapon_Wand_LightningPap2(int client, int weapon, bool &result, int slot)
{
	if (Ability_Check_Cooldown(client, slot) > 0.0)
	{
		float Ability_CD = Ability_Check_Cooldown(client, slot);

		if(Ability_CD <= 0.0)
			Ability_CD = 0.0;
	
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%T", "Ability has cooldown", client, Ability_CD);	
		return;
	}
	Weapon_Wand_LightningSpell(client, weapon, result, slot);
	Ability_Apply_Cooldown(client, slot, -1.0);
	Weapon_Wand_LightningPap(client, weapon, result, slot);

}
public void Weapon_Wand_LightningPap(int client, int weapon, bool &result, int slot)
{
	if(weapon >= MaxClients)
	{
		int mana_cost = Smite_Cost;
		if(mana_cost <= Current_Mana[client])
		{
			if (Ability_Check_Cooldown(client, slot) < 0.0)
			{
				Rogue_OnAbilityUse(client, weapon);
				Ability_Apply_Cooldown(client, slot, 20.0);
				
				float damage = Smite_BaseDMG;
				
				damage *= Smite_DMGMult;
				
				damage *= Attributes_Get(weapon, 410, 1.0);
			
				Smite_Damage[client] = damage;
					
				SDKhooks_SetManaRegenDelayTime(client, 1.0);
				Mana_Hud_Delay[client] = 0.0;
				
				Current_Mana[client] -= mana_cost;
					
				delay_hud[client] = 0.0;
				Damage_Reduction[client] = 1.0;
				
				float vAngles[3];
				float vOrigin[3];
				float vEnd[3];
	
				GetClientEyePosition(client, vOrigin);
				GetClientEyeAngles(client, vAngles);
				
				b_LagCompNPC_ExtendBoundingBox = true;
				StartLagCompensation_Base_Boss(client);
				Handle trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, BulletAndMeleeTrace, client);
				FinishLagCompensation_Base_boss();
				
				if(TR_DidHit(trace))
				{   	 
		   		 	TR_GetEndPosition(vEnd, trace);
					
					Handle pack;
					CreateDataTimer(Smite_ChargeSpan, Smite_Timer, pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
					WritePackCell(pack, GetClientUserId(client));
					WritePackFloat(pack, 0.0);
					WritePackFloat(pack, vEnd[0]);
					WritePackFloat(pack, vEnd[1]);
					WritePackFloat(pack, vEnd[2]);
					WritePackFloat(pack, damage);
					WritePackCell(pack, EntIndexToEntRef(weapon));
					
					EmitSoundToAll(SOUND_WAND_LIGHTNING_ABILITY_PAP_INTRO, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vEnd);
					EmitSoundToAll(SOUND_WAND_LIGHTNING_ABILITY_PAP_INTRO, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vEnd);
					spawnBeam(0.8, 255, 255, 0, 120, "materials/sprites/lgtning.vmt", 8.0, 8.2, _, 5.0, vOrigin, vEnd);
					spawnRing_Vectors(vEnd, Smite_Radius * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 255, 0, 200, 1, Smite_ChargeTime, 6.0, 0.1, 1, 1.0);
				}
				delete trace;
				
			}
			else
			{
				float Ability_CD = Ability_Check_Cooldown(client, slot);
		
				if(Ability_CD <= 0.0)
					Ability_CD = 0.0;
			
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
			}
		}
		else
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
		}
	}
}

public Action Smite_Timer(Handle Smite_Logic, DataPack pack)
{
	ResetPack(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	
	if (!IsValidClient(client))
	{
		return Plugin_Stop;
	}
		
	float NumLoops = ReadPackFloat(pack);
	float spawnLoc[3];
	for (int GetVector = 0; GetVector < 3; GetVector++)
	{
		spawnLoc[GetVector] = ReadPackFloat(pack);
	}
	
	float damage = ReadPackFloat(pack);
	int weapon = EntRefToEntIndex(ReadPackCell(pack));
	
	if(IsValidEntity(weapon))
	{
		if (NumLoops >= Smite_ChargeTime)
		{
			float secondLoc[3];
			for (int replace = 0; replace < 3; replace++)
			{
				secondLoc[replace] = spawnLoc[replace];
			}
			
			for (int sequential = 1; sequential <= 5; sequential++)
			{
				spawnRing_Vectors(secondLoc, 1.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 255, 0, 120, 1, 0.33, 6.0, 0.4, 1, (Smite_Radius * 5.0)/float(sequential));
				secondLoc[2] += 150.0 + (float(sequential) * 20.0);
			}
			
			secondLoc[2] = 9999.0;
			
			spawnBeam(0.8, 255, 255, 0, 255, "materials/sprites/laserbeam.vmt", 16.0, 16.2, _, 5.0, secondLoc, spawnLoc);	
			spawnBeam(0.8, 255, 255, 0, 200, "materials/sprites/lgtning.vmt", 10.0, 10.2, _, 5.0, secondLoc, spawnLoc);	
			spawnBeam(0.8, 255, 255, 0, 200, "materials/sprites/lgtning.vmt", 10.0, 10.2, _, 5.0, secondLoc, spawnLoc);	
			
			EmitAmbientSound(SOUND_WAND_LIGHTNING_ABILITY_PAP_SMITE, spawnLoc, _, 120);
			
			DataPack pack_boom = new DataPack();
			pack_boom.WriteFloat(spawnLoc[0]);
			pack_boom.WriteFloat(spawnLoc[1]);
			pack_boom.WriteFloat(spawnLoc[2]);
			pack_boom.WriteCell(1);
			RequestFrame(MakeExplosionFrameLater, pack_boom);
			
			Explode_Logic_Custom(damage, client, client, weapon, spawnLoc, Smite_Radius,_,_,false);
			
			return Plugin_Stop;
		}
		else
		{
			spawnRing_Vectors(spawnLoc, Smite_Radius * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 255, 0, 120, 1, 0.33, 6.0, 0.1, 1, 1.0);
			EmitAmbientSound(SOUND_WAND_LIGHTNING_ABILITY_PAP_CHARGE, spawnLoc, _, 60, _, _, GetRandomInt(80, 110));
			
			ResetPack(pack);
			WritePackCell(pack, GetClientUserId(client));
			WritePackFloat(pack, NumLoops + Smite_ChargeSpan);
			WritePackFloat(pack, spawnLoc[0]);
			WritePackFloat(pack, spawnLoc[1]);
			WritePackFloat(pack, spawnLoc[2]);
			WritePackFloat(pack, damage);
			WritePackCell(pack, EntIndexToEntRef(weapon));
		}
	}
	
	return Plugin_Continue;
}

static void spawnBeam(float beamTiming, int r, int g, int b, int a, char sprite[PLATFORM_MAX_PATH], float width=2.0, float endwidth=2.0, int fadelength=1, float amp=15.0, float startLoc[3] = {0.0, 0.0, 0.0}, float endLoc[3] = {0.0, 0.0, 0.0})
{
	int color[4];
	color[0] = r;
	color[1] = g;
	color[2] = b;
	color[3] = a;
		
	int SPRITE_INT = PrecacheModel(sprite, false);

	TE_SetupBeamPoints(startLoc, endLoc, SPRITE_INT, 0, 0, 0, beamTiming, width, endwidth, fadelength, amp, color, 0);
	
	TE_SendToAll();
}