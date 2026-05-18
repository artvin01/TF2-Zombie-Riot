function EmitSoundToClient(strSound, hPlayer)
{
	EmitSoundEx(
	{
		sound_name = strSound
		filter_type = RECIPIENT_FILTER_SINGLE_PLAYER
		entity = hPlayer
	})
}

function RAD2DEG(x)
{
	return (x * (180.0 / PI))
}

function DEG2RAD(x)
{
	return (x * (PI / 180.0))
}

// Valve Code
function AngleMatrix(vecAngles)
{
	local cy = DEG2RAD(vecAngles.y)
	local sy = sin(cy)
	cy = cos(cy)

	local cp = DEG2RAD(vecAngles.x)
	local sp = sin(cp)
	cp = cos(cp)

	local cr = DEG2RAD(vecAngles.z)
	local sr = sin(cr)
	cr = cos(cr)

	local crcy = cr*cy
	local crsy = cr*sy
	local srcy = sr*cy
	local srsy = sr*sy

	// matrix = (YAW * PITCH) * ROLL
	local aMatrix = []
	aMatrix.append(Vector(cp * cy, sp * srcy - crsy, (sp * crcy + srsy)))
	aMatrix.append(Vector(cp * sy, sp * srsy + crcy, (sp * crsy - srcy)))
	aMatrix.append(Vector(-sp, sr * cp, cr * cp))

	return aMatrix
}

function VectorRotate(in1, in2)
{
	if(typeof(in2) == "Vector" || typeof(in2) == "QAngle")
	{
		local aRotate = AngleMatrix(in2)
		return VectorRotate(in1, aRotate)
	}

	return Vector(in1.Dot(in2[0]), in1.Dot(in2[1]), in1.Dot(in2[2]))
}

// Rotates the 8 points to find a new mins/maxs square
function MinMaxsRotate(vecMin, vecMax, in2)
{
	local aRotate = in2
	if(typeof(in2) == "Vector" || typeof(in2) == "QAngle")
		aRotate = AngleMatrix(in2)

	local vecHighest = Vector(-99999.9, -99999.9, -99999.9)
	local vecLowest = Vector(99999.9, 99999.9, 99999.9)

	local vecPoint1 = Vector(vecMin.x, vecMin.y, vecMin.z)
	local vecPoint2 = Vector(vecMax.x, vecMax.y, vecMax.z)

	for(local i = 0; i < 4; i++)
	{
		switch(i)
		{
			case 1:	// Swap X
				vecPoint1.x = vecMax.x
				vecPoint2.x = vecMin.x
				break

			case 2:	// Swap X & Y
				vecPoint1.y = vecMax.y
				vecPoint2.y = vecMin.y
				break

			case 3:	// Swap Y
				vecPoint1.x = vecMin.x
				vecPoint2.x = vecMax.x
				break
		}

		local vecMins = VectorRotate(vecPoint1, aRotate)
		local vecMaxs = VectorRotate(vecPoint2, aRotate)

		if(vecHighest.x < vecMins.x)
			vecHighest.x = vecMins.x

		if(vecHighest.x < vecMaxs.x)
			vecHighest.x = vecMaxs.x

		if(vecHighest.y < vecMins.y)
			vecHighest.y = vecMins.y

		if(vecHighest.y < vecMaxs.y)
			vecHighest.y = vecMaxs.y

		if(vecHighest.z < vecMins.z)
			vecHighest.z = vecMins.z

		if(vecHighest.z < vecMaxs.z)
			vecHighest.z = vecMaxs.z

		if(vecLowest.x > vecMins.x)
			vecLowest.x = vecMins.x

		if(vecLowest.x > vecMaxs.x)
			vecLowest.x = vecMaxs.x

		if(vecLowest.y > vecMins.y)
			vecLowest.y = vecMins.y

		if(vecLowest.y > vecMaxs.y)
			vecLowest.y = vecMaxs.y

		if(vecLowest.z > vecMins.z)
			vecLowest.z = vecMins.z

		if(vecLowest.z > vecMaxs.z)
			vecLowest.z = vecMaxs.z
	}

	return [vecLowest, vecHighest]
}

function SafeBuildingPosition(hEntity, vecOrigin, vecMins, vecMaxs)
{
	// Raise up above stairs
	local tTrace =
	{
		start = vecOrigin
		end = vecOrigin - Vector(0.0, 0.0, vecMins.z - 32.0)
		mask = 0
		ignore = hEntity
	}
	TraceLineEx(tTrace)

	local vecNewOrigin = tTrace.endpos

	// Snap to the ground
	local tTrace =
	{
		start = vecNewOrigin
		end = vecOrigin - Vector(0.0, 0.0, 64.0)
		mask = 81931	// MASK_PLAYERSOLID_BRUSHONLY
		hullmin = vecMins
		hullmax = vecMaxs
		ignore = hEntity
	}
	TraceHull(tTrace)

	if(!tTrace.hit || tTrace.enthit == null)
		return null

	// Check if it's flat enough
	local vecPlane = tTrace.plane_normal
	if(0.7 > vecPlane.z)
		return null

	vecNewOrigin = tTrace.endpos + Vector(0.0, 0.0, 0.1)

	// Check for func_nobuild
	if(IsPointNoBuild(vecNewOrigin, vecMins, vecMaxs))
		return null

	// Check for objects in the way
	local tTrace =
	{
		start = vecNewOrigin
		end = vecNewOrigin
		mask = 33636363	// MASK_PLAYERSOLID
		hullmin = vecMins
		hullmax = vecMaxs
		ignore = hEntity
	}
	TraceHull(tTrace)

	if(tTrace.hit && tTrace.enthit != null)
		return null

	return vecNewOrigin
}

function IsPointNoBuild(vecPos, vecMins, vecMaxs)
{
	local aTriggers = []

	local hTrigger = null
	while(hTrigger = FindByClassname(hTrigger, "func_nobuild"))
	{
		hTrigger.RemoveSolidFlags(FSOLID_NOT_SOLID)
		aTriggers.append(hTrigger)
	}

	local tTrace =
	{
		start = vecPos
		end = vecPos
		mask = CONTENTS_SOLID
		hullmin = vecMins
		hullmax = vecMaxs
	}

	TraceHull(tTrace)

	foreach(hTrigger in aTriggers)
	{
		hTrigger.AddSolidFlags(FSOLID_NOT_SOLID)
	}

	return tTrace.hit
}

function TraceToBlock(hPlayer, flRange)
{
	local vecOrigin = hPlayer.EyePosition()
	local vecForward = hPlayer.EyeAngles().Forward()

	local aAvoid = []

	local hEntity = null
	while(hEntity = FindByClassname(hEntity, "player"))
	{
		if(!hEntity.IsSolidFlagSet(FSOLID_NOT_SOLID))
		{
			hEntity.AddSolidFlags(FSOLID_NOT_SOLID)
			aAvoid.append(hEntity)
		}
	}

	local tTrace =
	{
		start = vecOrigin
		end = vecOrigin + (vecForward * flRange)
		mask = (CONTENTS_SOLID|CONTENTS_MOVEABLE|CONTENTS_MONSTER|CONTENTS_WINDOW|CONTENTS_DEBRIS)
		ignore = hPlayer
	}
	TraceLineEx(tTrace)

	foreach(hEntit in aAvoid)
	{
		hEntit.RemoveSolidFlags(FSOLID_NOT_SOLID)
	}

	return tTrace
}

function GetClosestTarget(hEntity, flMaxDist = 9999.9, flMinDist = 0.0, bWalls = true)
{
	local vecOrigin = hEntity.GetOrigin()
	local hTarget = Entities.First()

	local hClosest = null
	local flClosest = flMaxDist

	while(hTarget = Entities.Next(hTarget))
	{
		if(!IsValidTarget(hEntity, hTarget, bWalls))
			continue

		local flDist = (vecOrigin - hEntity.GetOrigin()).Length()
		if(flDist < flMinDist || flDist > flMaxDist)
			continue

		hClosest = hTarget
		flClosest = flDist
	}

	return hClosest
}

function IsValidTarget(hEntity, hTarget, bWalls = true)
{
	if(!hTarget.IsValid())
		return false

	if(GetPropInt(hTarget, "m_takedamage") != 2)
		return false

	if(hTarget.GetFlags() & FL_NOTARGET)
		return false

	if(hEntity.GetTeam() == hTarget.GetTeam())
		return false

	local iHealth = GetPropInt(hTarget, "m_iHealth")
	if(iHealth < 1 || iHealth > 999999999)
		return false

	local strClassname = hTarget.GetClassname()
	if(strClassname == "player")
	{
		// Dead
		if(GetPropInt(hTarget, "m_lifeState") != 0)
			return false
	}
	else if(startswith(strClassname, "obj_"))
	{
		// Held building
		if(GetPropBool(hTarget, "m_bPlacing"))
			return false

		// Sapper or No Model
		if(GetPropInt(hTarget, "m_fObjectFlags") & (2|4))
			return false
	}
	else if(startswith(strClassname, "base_") || startswith(strClassname, "prop_") || startswith(strClassname, "func_"))
	{

	}
	else
	{
		// Ignore everything else
		return false
	}

	if(bWalls)
	{
		local tTrace =
		{
			start = hEntity.GetCenter()
			end = hTarget.GetCenter()
			mask = CONTENTS_SOLID|CONTENTS_MOVEABLE|CONTENTS_MONSTER|CONTENTS_WINDOW|CONTENTS_DEBRIS|CONTENTS_HITBOX|CONTENTS_GRATE
			ignore = hEntity
		}
		TraceLineEx(tTrace)

		if(tTrace.hit)
		{
		//	if(tTrace.enthit != hTarget)
		//		return false
		}
	}

	return true
}

function VectorAngles(vecVector)
{
	local flYaw, flPitch
	if(vecVector.y == 0.0 && vecVector.x == 0.0)
	{
		flYaw = 0.0
		flPitch = vecVector.z > 0.0 ? 270.0 : 90.0
	}
	else
	{
		flYaw = RAD2DEG(atan2(vecVector.y, vecVector.x))
		if(flYaw < 0.0)
			flYaw += 360.0

		flPitch = RAD2DEG(atan2(-vecVector.z, vecVector.Length2D()))
		if(flPitch < 0.0)
			flPitch += 360.0
	}
	return QAngle(flPitch, flYaw, 0.0)
}

function SetModelOverride(hEntity, strModel)
{
	local iModel = GetModelIndex(strModel)
	for(local i = 0; i < 4; i++)
	{
		SetPropIntArray(hEntity, "m_nModelIndexOverrides", iModel, i)
	}
}

function GetModelOfWeaponIndex(iIndex)
{
	local hWeapon = Entities.CreateByClassname("tf_weapon_bat")
	SetPropInt(hWeapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", iIndex)
	SetPropBool(hWeapon, "m_AttributeManager.m_Item.m_bInitialized", true)
	SetPropBool(hWeapon, "m_bValidatedAttachedEntity", true)
	hWeapon.SetTeam(TF_TEAM_RED)
	hWeapon.DispatchSpawn()

	local strModel = hWeapon.GetModelName()

	hWeapon.Kill()
	return strModel
}