#pragma semicolon 1
#pragma newdecls required

void NPCCamera_AddCamera(int entity)
{
	int camera = CreateEntityByName("info_observer_point");
	if(camera != -1)
	{
		DispatchKeyValue(camera, "fov", "70");
		DispatchKeyValue(camera, "TeamNum", "1");

		DispatchSpawn(camera);

		SetVariantString("!activator");
		AcceptEntityInput(camera, "SetParent", entity);

		float pos[3], ang[3];
		GetEntPropVector(entity, Prop_Data, "m_vecOrigin", pos);
		GetEntPropVector(entity, Prop_Data, "m_angRotation", ang);

		pos[2] += 40.0;
		TeleportEntity(camera, pos, ang, NULL_VECTOR);
	}
}