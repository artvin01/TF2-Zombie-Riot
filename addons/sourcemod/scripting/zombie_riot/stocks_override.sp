
void Stock_TakeDamage(int entity = 0, int inflictor = 0, int attacker = 0, float damage = 0.0, int damageType=DMG_GENERIC, int weapon=-1,const float damageForce[3]=NULL_VECTOR, const float damagePosition[3]=NULL_VECTOR, bool bypassHooks = false, int Zr_damage_custom = 0)
{
	i_HexCustomDamageTypes[entity] = Zr_damage_custom;
	
	SDKHooks_TakeDamage(entity, inflictor, attacker, damage, damageType, weapon, damageForce, damagePosition, bypassHooks);

}

//We need custom Defaults for this, mainly bypass hooks to FALSE. i dont want to spend 5 years on replacing everything.
//im sorry.
#define SDKHooks_TakeDamage Stock_TakeDamage

bool Stock_IsValidEntity(int entity)
{
	if(entity == 0)
	{
		return false;
	}
	else
	{
		return IsValidEntity(entity);
	}

}

#define IsValidEntity Stock_IsValidEntity

	

/*
TODO:
	Instead of setting the colour, try to get the average so gold and blue becomes a fusion of both,
	instead of just hard cold blue in the case of the wand. This would also make any 0 in ALPHA not seeable.

	Also how the fuck do i for loop this? This looks like shit

*/

//Override normal one to add our own logic for our own needs so we dont need to make a whole new thing.
stock void Stock_SetEntityRenderMode(int entity, RenderMode mode, bool TrueEntityColour = true, int SetOverride = 0, bool ingore_wearables = true, bool dontchangewearablecolour = true)
{
	if(TrueEntityColour || SetOverride != 0)
	{
		if(!ingore_wearables && !dontchangewearablecolour)
		{
			//clean... er... :)
			for(int WearableSlot=0; WearableSlot<=5; WearableSlot++)
			{
				int WearableEntityIndex = EntRefToEntIndex(i_Wearable[entity][WearableSlot]);
				if(IsValidEntity(WearableEntityIndex))
				{	
					if(i_EntityRenderColour4[WearableEntityIndex] != 0)
					{
						if(SetOverride == 1)
						{
							i_EntityRenderOverride[WearableEntityIndex] = true;
						}
						else if (SetOverride == 2)
						{
							i_EntityRenderOverride[WearableEntityIndex] = false;
						}
						i_EntityRenderMode[WearableEntityIndex] = mode;		
					}
				}
			}
		}
		if(i_EntityRenderColour4[entity] != 0) //If it has NO colour, then do NOT recolour.
		{
			if(SetOverride == 1)
			{
				i_EntityRenderOverride[entity] = true;
			}
			else if (SetOverride == 2)
			{
				i_EntityRenderOverride[entity] = false;
			}
			i_EntityRenderMode[entity] = mode;
		}
	}
		
	if(!i_EntityRenderOverride[entity] || !TrueEntityColour)
	{
		if(!ingore_wearables)
		{
			//clean... er... :)
			for(int WearableSlot=0; WearableSlot<=5; WearableSlot++)
			{
				int WearableEntityIndex = EntRefToEntIndex(i_Wearable[entity][WearableSlot]);
				if(IsValidEntity(WearableEntityIndex))
				{	
					if(i_EntityRenderColour4[WearableEntityIndex] != 0)
					{					
						if(!TrueEntityColour)
						{
							SetEntityRenderMode(WearableEntityIndex, mode);		
						}
						else
						{
							SetEntityRenderMode(WearableEntityIndex, i_EntityRenderMode[WearableEntityIndex]);		
						}	
					}
				}
			}
		}
		if(i_EntityRenderColour4[entity] != 0 && !i_EntityRenderOverride[entity] || (!TrueEntityColour && i_EntityRenderColour4[entity] != 0)) //If it has NO colour, then do NOT recolour.
		{
			SetEntityRenderMode(entity, mode);
		}
	}
}

#define SetEntityRenderMode Stock_SetEntityRenderMode


//Override normal one to add our own logic for our own needs so we dont need to make a whole new thing.
stock void Stock_SetEntityRenderColor(int entity, int r=255, int g=255, int b=255, int a=255, bool TrueEntityColour = true, bool ingore_wearables = true, bool dontchangewearablecolour = true)
{	
	bool ColorWasSet = false;
	if(TrueEntityColour)
	{
		if(!ingore_wearables && !dontchangewearablecolour)
		{
			//clean... er... :)
			for(int WearableSlot=0; WearableSlot<=5; WearableSlot++)
			{
				int WearableEntityIndex = EntRefToEntIndex(i_Wearable[entity][WearableSlot]);
				if(IsValidEntity(WearableEntityIndex))
				{	
					if(i_EntityRenderColour4[WearableEntityIndex] != 0)
					{
						i_EntityRenderColour1[WearableEntityIndex] = r;
						i_EntityRenderColour2[WearableEntityIndex] = g;
						i_EntityRenderColour3[WearableEntityIndex] = b;
						i_EntityRenderColour4[WearableEntityIndex] = a;
					}
				}
			}
		}
		if(i_EntityRenderColour4[entity] != 0) //If it has NO colour, then do NOT recolour.
		{
			i_EntityRenderColour1[entity] = r;
			i_EntityRenderColour2[entity] = g;
			i_EntityRenderColour3[entity] = b;
			i_EntityRenderColour4[entity] = a;
			ColorWasSet = true;
		}
	}
	
	if(!i_EntityRenderOverride[entity] || !TrueEntityColour)
	{
		if(!ingore_wearables)
		{
			//clean... er... :)
			for(int WearableSlot=0; WearableSlot<=5; WearableSlot++)
			{
				int WearableEntityIndex = EntRefToEntIndex(i_Wearable[entity][WearableSlot]);
				if(IsValidEntity(WearableEntityIndex))
				{	
					if(i_EntityRenderColour4[WearableEntityIndex] != 0)
					{
						if(!TrueEntityColour)
						{
							SetEntityRenderColor(WearableEntityIndex, r, g, b, a);
						}
						else
						{
							SetEntityRenderColor(WearableEntityIndex,
							i_EntityRenderColour1[WearableEntityIndex],
							i_EntityRenderColour2[WearableEntityIndex],
							i_EntityRenderColour3[WearableEntityIndex],
							i_EntityRenderColour4[WearableEntityIndex]);
						}	
					}						
				}
			}
		}
		if((i_EntityRenderColour4[entity] != 0 && !i_EntityRenderOverride[entity]) || (ColorWasSet && !i_EntityRenderOverride[entity]) || (!TrueEntityColour && i_EntityRenderColour4[entity] != 0)) //If it has NO colour, then do NOT recolour.
		{
			SetEntityRenderColor(entity, r, g, b, a);
		}
	}
}

#define SetEntityRenderColor Stock_SetEntityRenderColor

//In this case i never need the world ever.

void Stock_SetHudTextParams(float x, float y, float holdTime, int r, int g, int b, int a, int effect = 1, float fxTime=0.1, float fadeIn=0.1, float fadeOut=0.1)
{
	SetHudTextParams(x, y, holdTime, r, g, b, a, effect, fxTime, fadeIn, fadeOut);
}

#define SetHudTextParams Stock_SetHudTextParams

stock void ResetToZero(any[] array, int length)
{
    for(int i; i<length; i++)
    {
        array[i] = 0;
    }
}

stock void ResetToZero2(any[][] array, int length1, int length2)
{
    for(int a; a<length1; a++)
    {
        for(int b; b<length2; b++)
        {
            array[a][b] = 0;
        }
    }
}

#define Zero(%1)        ResetToZero(%1, sizeof(%1))
#define Zero2(%1)    ResetToZero2(%1, sizeof(%1), sizeof(%1[]))