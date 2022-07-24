#include <sourcemod>
#include <dhooks>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "Grenade Tweaks",
	author = "Vauff, BotoX",
	description = "Removes smoke particles & audio ringing from HE grenade explosions",
	version = "2.0.1",
	url = "https://github.com/Vauff/GrenadeTweaks"
};

Handle g_hGetParticleSystemName;
Handle g_hDamagedByExplosion;

public void OnPluginStart()
{
	char path[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, path, sizeof(path), "gamedata/GrenadeTweaks.games.txt");

	if (!FileExists(path))
		SetFailState("Can't find GrenadeTweaks.games.txt gamedata");

	Handle gameData = LoadGameConfigFile("GrenadeTweaks.games");
	
	if (gameData == INVALID_HANDLE)
		SetFailState("Can't find GrenadeTweaks.games.txt gamedata");

	g_hGetParticleSystemName = DHookCreate(GameConfGetOffset(gameData, "GetParticleSystemName"), HookType_Entity, ReturnType_CharPtr, ThisPointer_Ignore, Hook_GetParticleSystemName);
	DHookAddParam(g_hGetParticleSystemName, HookParamType_Int);
	DHookAddParam(g_hGetParticleSystemName, HookParamType_ObjectPtr);

	g_hDamagedByExplosion = DHookCreate(GameConfGetOffset(gameData, "OnDamagedByExplosion"), HookType_Entity, ReturnType_Void, ThisPointer_Ignore, Hook_OnDamagedByExplosion);
	DHookAddParam(g_hDamagedByExplosion, HookParamType_ObjectPtr);

	CloseHandle(gameData);

	if (!g_hGetParticleSystemName)
		SetFailState("Failed to setup hook for GetParticleSystemName");

	if (!g_hDamagedByExplosion)
		SetFailState("Failed to setup hook for OnDamagedByExplosion");
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if (StrEqual(classname, "hegrenade_projectile"))
		DHookEntity(g_hGetParticleSystemName, false, entity);
}

public void OnClientPutInServer(int client)
{
	DHookEntity(g_hDamagedByExplosion, false, client);
}

//void CCSPlayer::OnDamagedByExplosion(const CTakeDamageInfo &info)
public MRESReturn Hook_OnDamagedByExplosion(int pThis, Handle hReturn, Handle hParams)
{
	return MRES_Supercede;
}

//const char *CHEGrenadeProjectile::GetParticleSystemName(int pointContents, surfacedata_t *pdata)
public MRESReturn Hook_GetParticleSystemName(DHookReturn hReturn, DHookParam hParams)
{
	int pointContents;
	pointContents = DHookGetParam(hParams, 1);

	if (pointContents & MASK_WATER)
		DHookSetReturnString(hReturn, "explosion_basic_water");
	else
		DHookSetReturnString(hReturn, "explosion_hegrenade_brief");

	return MRES_Supercede;
}