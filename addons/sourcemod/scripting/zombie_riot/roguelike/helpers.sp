/*
	RogueHelp_WeaponDamage(entity, );
	RogueHelp_WeaponAPSD(entity, );

	RogueHelp_BodyDamage(entity, map, );
	RogueHelp_BodyHealth(entity, map, );
	RogueHelp_BodyAPSD(entity, map, );
	RogueHelp_BodyRes(entity, map, );
	RogueHelp_BodySpeed(entity, map, );
*/
#pragma semicolon 1
#pragma newdecls required

stock void RogueHelp_WeaponDamage(int entity, float amount)
{
	if(Attributes_Has(entity, 2))
		Attributes_SetMulti(entity, 2, amount);
	
	if(Attributes_Has(entity, 8))
		Attributes_SetMulti(entity, 8, amount);
	
	if(Attributes_Has(entity, 410))
		Attributes_SetMulti(entity, 410, amount);
}

stock void RogueHelp_WeaponAPSD(int entity, float amount)
{
	if(Attributes_Has(entity, 6))
		Attributes_SetMulti(entity, 6, 1.0 / amount);
	
	if(Attributes_Has(entity, 8))
		Attributes_SetMulti(entity, 8, amount);
	
	if(Attributes_Has(entity, 97))
		Attributes_SetMulti(entity, 97, 1.0 / amount);
}

stock void RogueHelp_BodyDamage(int entity, StringMap map, float amount)
{
	if(map)	// Player
	{
		float value;

		value = 1.0;
		map.GetValue("287", value);
		map.SetValue("287", value * amount);
	}
	else if(!b_NpcHasDied[entity])	// NPCs
	{
		if(Citizen_IsIt(entity))	// Rebel
		{
			Citizen npc = view_as<Citizen>(entity);
			npc.m_fGunBonusDamage *= amount;
		}
		else
		{
			BarrackBody npc = view_as<BarrackBody>(entity);
			if(npc.OwnerUserId)	// Barracks Unit
			{
				npc.BonusDamageBonus *= amount;
			}
			else
			{
				fl_Extra_Damage[entity] *= amount;
			}
		}
	}
}

stock void RogueHelp_BodyAPSD(int entity, StringMap map, float amount)
{
	if(map)	// Player
	{
		float value;

		value = 1.0;
		map.GetValue("343", value);
		map.SetValue("343", value * amount);
	}
	else if(!b_NpcHasDied[entity])	// NPCs
	{
		if(Citizen_IsIt(entity))	// Rebel
		{
			Citizen npc = view_as<Citizen>(entity);
			npc.m_fGunBonusFireRate /= amount;
			npc.m_fGunReload /= amount;
		}
		else
		{
			BarrackBody npc = view_as<BarrackBody>(entity);
			if(npc.OwnerUserId)	// Barracks Unit
			{
				npc.BonusFireRate *= amount;
			}
			else
			{
				f_AttackSpeedNpcIncrease[entity] /= amount;
			}
		}
	}
}

stock void RogueHelp_BodyRes(int entity, StringMap map = null, float amount)
{
	if(map)	// Player
	{
		float value;

		map.GetValue("412", value);
		map.SetValue("412", value / amount);
	}
	else if(!b_NpcHasDied[entity])	// NPCs
	{
		fl_Extra_MeleeArmor[entity] /= amount;
		fl_Extra_RangedArmor[entity] /= amount;
	}
}

stock void RogueHelp_BodyHealth(int entity, StringMap map = null, float amount)
{
	if(map)	// Player
	{
		float value;

		map.GetValue("26", value);
		map.SetValue("26", value * amount);

		value = 1.0;
		map.GetValue("286", value);
		map.SetValue("286", value * amount);
	}
	else if(!b_NpcHasDied[entity])	// NPCs
	{
		SetEntProp(entity, Prop_Data, "m_iHealth", RoundFloat(GetEntProp(entity, Prop_Data, "m_iHealth") * amount));
		SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundFloat(ReturnEntityMaxHealth(entity) * amount));
	}
}

stock void RogueHelp_BodySpeed(int entity, StringMap map, float amount)
{
	if(map)	// Player
	{
		float value;

		value = 1.0;
		map.GetValue("442", value);
		map.SetValue("442", value * amount);
	}
	else if(!b_NpcHasDied[entity])	// NPCs
	{
		fl_Extra_Speed[entity] *= amount;
	}
}