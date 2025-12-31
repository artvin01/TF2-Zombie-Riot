#pragma semicolon 1
#pragma newdecls required

public void Weapon_Mangler(int client, int weapon, bool crit, int slot)
{
	int new_ammo = GetAmmo(client, 23);
	if(new_ammo < 10)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		PrintHintText(client,"레이저 배터리 탄창이 전부 소진되었습니다!");
		return;
	}
	new_ammo -= 10;
	SetAmmo(client, 23, new_ammo);
	CurrentAmmo[client][23] = GetAmmo(client, 23);
	
	PrintHintText(client,"레이저 배터리: %i", new_ammo);

	float damage = 112.0;
	damage *= Attributes_Get(weapon, 1, 1.0);
	damage *= Attributes_Get(weapon, 2, 1.0);

	Player_Laser_Logic Laser;
	float Radius = 10.0;
	Laser.client = client;
	Laser.Radius = Radius;
	Laser.damagetype = DMG_PLASMA;
	Laser.DoForwardTrace_Basic(1500.0);
	PlayerLaserDoDamageCombined(Laser, damage, damage);
	Offset_Vector({0.0, -8.0, -10.0}, Laser.Angles, Laser.Start_Point);
	int color[4] = {255, 0, 0, 60};
	DoPlayerLaserEffectsBigger(Laser, color);

}
void DoPlayerLaserEffectsBigger(Player_Laser_Logic Laser, int color[4])
{	
	float diameter = Laser.Radius * 2.0;

	int colorLayer3[4];
	SetColorRGBA(colorLayer3, color[0] * 7 + 255 / 8, color[1] * 7 + 255 / 8, color[2] * 7 + 255 / 8, color[3]);
	int colorLayer2[4];
	SetColorRGBA(colorLayer2, color[0] * 6 + 510 / 8, color[1] * 6 + 510 / 8, color[2] * 6 + 510 / 8, color[3]);
	int colorLayer1[4];
	SetColorRGBA(colorLayer1, color[0] * 5 + 765 / 8, color[1] * 5 + 765 / 8, color[2] * 5 + 765 / 8, color[3]);
	TE_SetupBeamPoints(Laser.Start_Point, Laser.End_Point, g_Ruina_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.3 * 1.28), ClampBeamWidth(diameter * 0.3 * 1.28), 0, 1.0, colorLayer1, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(Laser.Start_Point, Laser.End_Point, g_Ruina_BEAM_Laser, 0, 0, 0, 0.22, ClampBeamWidth(diameter * 0.5 * 1.28), ClampBeamWidth(diameter * 0.5 * 1.28), 0, 1.0, colorLayer2, 3);
	TE_SendToAll(0.0);
//	TE_SetupBeamPoints(Laser.Start_Point, Laser.End_Point, g_Ruina_BEAM_Laser, 0, 0, 0, 0.22, ClampBeamWidth(diameter * 0.8 * 1.28), ClampBeamWidth(diameter * 0.8 * 1.28), 0, 1.0, colorLayer3, 3);
//	TE_SendToAll(0.0);
// I have removed one TE as its way too many te's at once.
	TE_SetupBeamPoints(Laser.Start_Point, Laser.End_Point, g_Ruina_BEAM_Laser, 0, 0, 0, 0.33, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 1.0, color, 3);
	TE_SendToAll(0.0);
	int glowColor[4];
	SetColorRGBA(glowColor, color[0], color[1], color[2], color[3]);
	TE_SetupBeamPoints(Laser.Start_Point, Laser.End_Point, g_Ruina_BEAM_Glow, 0, 0, 0, 0.33, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 5.0, glowColor, 0);
	TE_SendToAll(0.0);
}
void PlayerLaserDoDamageCombined(Player_Laser_Logic Laser, float Close_Dps, float Long_Dps)
{
	Laser.weapon = GetEntPropEnt(Laser.client, Prop_Send, "m_hActiveWeapon");
	float TargetsHitFallOff = 1.0;
	Laser.Enumerate_Simple();

	float Falloff = LASER_AOE_DAMAGE_FALLOFF;

	if(Laser.target_hitfalloff)
		Falloff = Laser.target_hitfalloff;

	for (int loop = 0; loop < sizeof(i_Ruina_Laser_BEAM_HitDetected); loop++)
	{
		//get victims from the "Enumerate_Simple"
		int victim = i_Ruina_Laser_BEAM_HitDetected[loop];
		if(!victim)
			break;	//no more targets are left, break the loop!

		float playerPos[3];
		GetEntPropVector(victim, Prop_Send, "m_vecOrigin", playerPos, 0);
		float Dist = GetVectorDistance(Laser.Start_Point, playerPos);

		float Ratio = Dist / Laser.MaxDist;
		float damage = Close_Dps + (Long_Dps-Close_Dps) * Ratio;

		//somehow negative damage. invert.
		if (damage < 0)
			damage *= -1.0;

		Laser.DoDamage(victim, damage*TargetsHitFallOff, Laser.weapon, {0.0,0.0,0.0});
		
		//SDKHooks_TakeDamage(victim, Laser.client, Laser.client, damage*TargetsHitFallOff, DMG_PLASMA);
		TargetsHitFallOff *= Falloff;
	}
}


public void Weapon_ManglerLol(int client, int weapon, bool crit, int slot)
{
	float damage = 112.0;
	damage *= Attributes_Get(weapon, 1, 1.0);
	damage *= Attributes_Get(weapon, 2, 1.0);

	Player_Laser_Logic Laser;
	float Radius = 10.0;
	Laser.client = client;
	Laser.Radius = Radius;
	Laser.damagetype = DMG_PLASMA;
	Laser.DoForwardTrace_Basic(1500.0);
	PlayerLaserDoDamageCombined(Laser, damage, damage);
	Offset_Vector({0.0, -8.0, -10.0}, Laser.Angles, Laser.Start_Point);
	int color[4] = {255, 0, 0, 60};
	DoPlayerLaserEffectsBigger(Laser, color);
}

float AttackDelayBobGun[MAXPLAYERS];
public void Weapon_BobsGunBullshit(int client, int weapon, bool crit, int slot)
{
	AttackDelayBobGun[client] = 0.0;
	SDKUnhook(client, SDKHook_PreThink, BobsGunM2_PreThink);
	SDKHook(client, SDKHook_PreThink, BobsGunM2_PreThink);
}

public void BobsGunM2_PreThink(int client)
{
	if(GetClientButtons(client) & IN_ATTACK2)
	{
		if(AttackDelayBobGun[client] > GetGameTime())
		{
			return;
		}
		AttackDelayBobGun[client] = GetGameTime() + 0.05;
		int weapon_active = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(weapon_active < 0)
		{
			SDKUnhook(client, SDKHook_PreThink, BobsGunM2_PreThink);
			return;
		}
		if(i_CustomWeaponEquipLogic[weapon_active] != WEAPON_BOBS_GUN)
		{
			SDKUnhook(client, SDKHook_PreThink, BobsGunM2_PreThink);
			return;
		}
		b_LagCompNPC_No_Layers = true;
		StartLagCompensation_Base_Boss(client);

		Handle swingTrace;
		float vecSwingForward[3];
		float pos[3];
		DoSwingTrace_Custom(swingTrace, client, vecSwingForward, 9999.9, false, 45.0, true); //infinite range, and ignore walls!
					
		TR_GetEndPosition(pos, swingTrace);
		delete swingTrace;
		
		TE_Particle("ExplosionCore_MidAir", pos, NULL_VECTOR, NULL_VECTOR, 
		_, _, _, _, _, _, _, _, _, _, 0.0);

		float damage = 112.0;

		damage *= 7.0;
		
		damage *= Attributes_Get(weapon_active, 1, 1.0);
						
		damage *= Attributes_Get(weapon_active, 2, 1.0);
		switch(GetRandomInt(1,3))
		{
			case 1:
			{
				EmitAmbientSound("weapons/explode1.wav", pos, _, 85, _,0.9, GetRandomInt(95, 105));
			}
			case 2:
			{
				EmitAmbientSound("weapons/explode2.wav", pos, _, 85, _,0.9, GetRandomInt(95, 105));
			}
			case 3:
			{
				EmitAmbientSound("weapons/explode3.wav", pos, _, 85, _,0.9, GetRandomInt(95, 105));
			}
		}
		Explode_Logic_Custom(damage, client, client, weapon_active, pos);
		EmitSoundToAll("weapons/shotgun/shotgun_fire7.wav", client, SNDCHAN_WEAPON, 80, _, 1.0);

		FinishLagCompensation_Base_boss();
	}
	else
	{
		SDKUnhook(client, SDKHook_PreThink, BobsGunM2_PreThink);
		return;
	}
}