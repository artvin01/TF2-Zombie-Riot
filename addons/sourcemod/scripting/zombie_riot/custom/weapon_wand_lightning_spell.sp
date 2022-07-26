static float ability_cooldown[MAXPLAYERS+1]={0.0, ...};
static float Fireball_Damage[MAXPLAYERS+1]={0.0, ...};
static int gLaser1;
#define SOUND_WAND_LIGHTNING_ABILITY "ambient/explosions/explode_9.wav"

static char gGlow1;
static char gExplosive1;

void Wand_LightningAbility_Map_Precache()
{
	gLaser1 = PrecacheModel("materials/sprites/laser.vmt");
	PrecacheSound(SOUND_WAND_LIGHTNING_ABILITY);

	gLaser1 = PrecacheModel("materials/sprites/laser.vmt");
	gGlow1 = PrecacheModel("sprites/blueglow2.vmt", true);
	gExplosive1 = PrecacheModel("materials/sprites/sprite_fire01.vmt");
	PrecacheModel("models/props_wasteland/rockgranite03b.mdl");
	PrecacheModel("models/weapons/w_bullet.mdl");
	PrecacheModel("models/weapons/w_grenade.mdl");
	PrecacheModel("models/monk.mdl");
	PrecacheSound("ambient/explosions/explode_9.wav",true);
	PrecacheSound("ambient/energy/weld1.wav",true);
	PrecacheSound("ambient/halloween/mysterious_perc_01.wav",true);
	
	PrecacheSound("player/flow.wav");
}

public void Lighting_Wand_Spell_ClearAll()
{
	Zero(ability_cooldown);
}

public void Weapon_Wand_LightningSpell(int client, int weapon, const char[] classname, bool &result)
{
	if(weapon >= MaxClients)
	{
		int mana_cost = 100;
		if(mana_cost <= Current_Mana[client])
		{
			if (ability_cooldown[client] < GetGameTime())
			{
				ability_cooldown[client] = GetGameTime() + 15.0; //10 sec CD
				
				float damage = 200.0;
				
				damage *= 7.5;
				
				Address address = TF2Attrib_GetByDefIndex(weapon, 410);
				if(address != Address_Null)
					damage *= TF2Attrib_GetValue(address);
			
				Fireball_Damage[client] = damage;
					
				Mana_Regen_Delay[client] = GetGameTime() + 1.0;
				Mana_Hud_Delay[client] = 0.0;
				
				Current_Mana[client] -= mana_cost;
					
				delay_hud[client] = 0.0;
				
				float vAngles[3];
				float vOrigin[3];
				float vEnd[3];
	
				GetClientEyePosition(client, vOrigin);
				GetClientEyeAngles(client, vAngles);
				Handle trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, Trace_DontHitEntityOrPlayer);
				
				if(TR_DidHit(trace))
				{   	 
		   		 	TR_GetEndPosition(vEnd, trace);
			
					CloseHandle(trace);
					
					Explode_Logic_Custom(damage, client, client, weapon, vEnd,_,_,_,false);
					
					float position[3];
					position[0] = vEnd[0];
					position[1] = vEnd[1];
					position[2] += 1500.0;
					
					int r = 255;
					int g = 255;
					int b = 0;
					int alpha = 125;
					int diameter = 25;
					
					int colorLayer4[4];
					SetColorRGBA(colorLayer4, r, g, b, alpha);
					int colorLayer3[4];
					SetColorRGBA(colorLayer3, colorLayer4[0] * 7 + 255 / 8, colorLayer4[1] * 7 + 255 / 8, colorLayer4[2] * 7 + 255 / 8, alpha);
					int colorLayer2[4];
					SetColorRGBA(colorLayer2, colorLayer4[0] * 6 + 510 / 8, colorLayer4[1] * 6 + 510 / 8, colorLayer4[2] * 6 + 510 / 8, alpha);
					int colorLayer1[4];
					SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, alpha);
					TE_SetupBeamPoints(vEnd, position, gLaser1, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.3 * 1.28), ClampBeamWidth(diameter * 0.3 * 1.28), 0, 1.0, colorLayer1, 3);
					TE_SendToAll(0.0);
					TE_SetupBeamPoints(vEnd, position, gLaser1, 0, 0, 0, 0.22, ClampBeamWidth(diameter * 0.5 * 1.28), ClampBeamWidth(diameter * 0.5 * 1.28), 0, 1.0, colorLayer2, 3);
					TE_SendToAll(0.0);
					TE_SetupBeamPoints(vEnd, position, gLaser1, 0, 0, 0, 0.22, ClampBeamWidth(diameter * 0.8 * 1.28), ClampBeamWidth(diameter * 0.8 * 1.28), 0, 1.0, colorLayer3, 3);
					TE_SendToAll(0.0);
					TE_SetupBeamPoints(vEnd, position, gLaser1, 0, 0, 0, 0.33, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 1.0, colorLayer4, 3);
					TE_SendToAll(0.0);
					int glowColor[4];
					SetColorRGBA(glowColor, r, g, b, alpha);
					
					int particle_extra;
					float Angles[3];
					
					particle_extra = ParticleEffectAt(vEnd, "utaunt_lightning_bolt", 1.0);
					Angles [1] = GetRandomFloat(-180.0, 180.0);
					TeleportEntity(particle_extra, NULL_VECTOR, Angles, NULL_VECTOR);
					
					particle_extra = ParticleEffectAt(vEnd, "utaunt_lightning_bolt", 1.0);
					Angles [1] = GetRandomFloat(-180.0, 180.0);
					TeleportEntity(particle_extra, NULL_VECTOR, Angles, NULL_VECTOR);
					
					particle_extra = ParticleEffectAt(vEnd, "utaunt_lightning_bolt", 1.0);
					Angles [1] = GetRandomFloat(-180.0, 180.0);
					TeleportEntity(particle_extra, NULL_VECTOR, Angles, NULL_VECTOR);
					
					TE_SetupBeamPoints(vEnd, position, gLaser1, 0, 0, 0, 0.33, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 5.0, glowColor, 0);
					TE_SendToAll(0.0);
					EmitSoundToAll(SOUND_WAND_LIGHTNING_ABILITY, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vEnd);
					EmitSoundToAll(SOUND_WAND_LIGHTNING_ABILITY, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vEnd);	

				}
				
			}
			else
			{
				float Ability_CD = ability_cooldown[client] - GetGameTime();
		
				if(Ability_CD <= 0.0)
					Ability_CD = 0.0;
			
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
			}
		}
		else
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
		}
	}
}


/*
	LightningStrike_IOC_Invoke(int client, int vecTarget, float duration_delay, float IOCDist, float IOCdamage);

*/





public Action LightningStrike_DrawIon(Handle Timer, any data)
{
	LightningStrike_IonAttack(data);
		
	return (Plugin_Stop);
}
	
public void LightningStrike_DrawIonBeam(float startPosition[3], const int color[4])
{
	float position[3];
	position[0] = startPosition[0];
	position[1] = startPosition[1];
	position[2] = startPosition[2] + 3000.0;	
	
	TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 0.15, 25.0, 25.0, 0, NORMAL_ZOMBIE_VOLUME, color, 3 );
	TE_SendToAll();
	position[2] -= 1490.0;
	TE_SetupGlowSprite(startPosition, gGlow1, NORMAL_ZOMBIE_VOLUME, NORMAL_ZOMBIE_VOLUME, 255);
	TE_SendToAll();
}

	public void LightningStrike_IonAttack(Handle &data)
	{
		float startPosition[3];
		float position[3];
		startPosition[0] = ReadPackFloat(data);
		startPosition[1] = ReadPackFloat(data);
		startPosition[2] = ReadPackFloat(data);
		float Iondistance = ReadPackCell(data);
		float nphi = ReadPackFloat(data);
		int Ionrange = ReadPackCell(data);
		int Iondamage = ReadPackCell(data);
		int client = ReadPackCell(data);
		
		if (Iondistance > 0)
		{
			EmitSoundToAll("ambient/energy/weld1.wav", 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, startPosition);
			
			// Stage 1
			float s=Sine(nphi/360*6.28)*Iondistance;
			float c=Cosine(nphi/360*6.28)*Iondistance;
			
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[2] = startPosition[2];
			
			position[0] += s;
			position[1] += c;
			LightningStrike_DrawIonBeam(position, {0, 150, 255, 255});
	
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[0] -= s;
			position[1] -= c;
			LightningStrike_DrawIonBeam(position, {0, 150, 255, 255});
			
			// Stage 2
			s=Sine((nphi+45.0)/360*6.28)*Iondistance;
			c=Cosine((nphi+45.0)/360*6.28)*Iondistance;
			
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[0] += s;
			position[1] += c;
			LightningStrike_DrawIonBeam(position, {0, 150, 255, 255});
			
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[0] -= s;
			position[1] -= c;
			LightningStrike_DrawIonBeam(position, {0, 150, 255, 255});
			
			// Stage 3
			s=Sine((nphi+90.0)/360*6.28)*Iondistance;
			c=Cosine((nphi+90.0)/360*6.28)*Iondistance;
			
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[0] += s;
			position[1] += c;
			LightningStrike_DrawIonBeam(position,{0, 150, 255, 255});
			
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[0] -= s;
			position[1] -= c;
			LightningStrike_DrawIonBeam(position,{0, 150, 255, 255});
			
			// Stage 3
			s=Sine((nphi+135.0)/360*6.28)*Iondistance;
			c=Cosine((nphi+135.0)/360*6.28)*Iondistance;
			
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[0] += s;
			position[1] += c;
			LightningStrike_DrawIonBeam(position, {0, 150, 255, 255});
			
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[0] -= s;
			position[1] -= c;
			LightningStrike_DrawIonBeam(position, {0, 150, 255, 255});
	
			if (nphi >= 360)
				nphi = 0.0;
			else
				nphi += 5.0;
		}
		Iondistance -= 5;
		
		Handle nData = CreateDataPack();
		WritePackFloat(nData, startPosition[0]);
		WritePackFloat(nData, startPosition[1]);
		WritePackFloat(nData, startPosition[2]);
		WritePackCell(nData, Iondistance);
		WritePackFloat(nData, nphi);
		WritePackCell(nData, Ionrange);
		WritePackCell(nData, Iondamage);
		WritePackCell(nData, client);
		ResetPack(nData);
		
		if (Iondistance > -50)
		CreateTimer(0.1, LightningStrike_DrawIon, nData, TIMER_FLAG_NO_MAPCHANGE|TIMER_DATA_HNDL_CLOSE);
		else
		{
			makeexplosion(-1, -1, startPosition, "", 0, 0);
			
			Explode_Logic_Custom(float(Iondamage), client, client, -1, startPosition, float(Ionrange), _, _, false);
			
			
			TE_SetupExplosion(startPosition, gExplosive1, 10.0, 1, 0, 0, 0);
			TE_SendToAll();
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[2] += startPosition[2] + 900.0;
			startPosition[2] += -200;
			TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 2.0, 30.0, 30.0, 0, NORMAL_ZOMBIE_VOLUME, {255, 255, 255, 255}, 3);
			TE_SendToAll();
			TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 2.0, 50.0, 50.0, 0, NORMAL_ZOMBIE_VOLUME, {200, 255, 255, 255}, 3);
			TE_SendToAll();
			TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 2.0, 80.0, 80.0, 0, NORMAL_ZOMBIE_VOLUME, {100, 255, 255, 255}, 3);
			TE_SendToAll();
			TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 2.0, 100.0, 100.0, 0, NORMAL_ZOMBIE_VOLUME, {0, 255, 255, 255}, 3);
			TE_SendToAll();
	
			position[2] = startPosition[2] + 50.0;
			//new Float:fDirection[3] = {-90.0,0.0,0.0};
			//env_shooter(fDirection, 25.0, 0.1, fDirection, 800.0, 120.0, 120.0, position, "models/props_wasteland/rockgranite03b.mdl");
	
			//env_shake(startPosition, 120.0, 10000.0, 15.0, 250.0);
			
			// Sound
			EmitSoundToAll("ambient/explosions/explode_9.wav", 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, startPosition);
		}
}

public void LightningStrike_IOC_Invoke(int client, float vecTarget[3], float duration_delay, float IOCDist , float IOCdamage)
{
	Handle data = CreateDataPack();
	WritePackFloat(data, vecTarget[0]);
	WritePackFloat(data, vecTarget[1]);
	WritePackFloat(data, vecTarget[2]);
	WritePackCell(data, duration_delay); // Distance
	WritePackFloat(data, 0.0); // nphi
	WritePackCell(data, IOCDist); // Range
	WritePackCell(data, IOCdamage); // Damge
	WritePackCell(data, client);
	ResetPack(data);
	LightningStrike_IonAttack(data);
		
}