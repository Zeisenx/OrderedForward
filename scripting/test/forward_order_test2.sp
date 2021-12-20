
#include <sourcemod>
#include <sdkhooks>
#include <forward_order>

OrderForward g_fwTest;

public void FO_OnReadyPost()
{
	g_fwTest = FO_FindForward("OnTakeDamage");
	g_fwTest.RequestFunc(OnTakeDamage);
	
	PrintToChatAll("got findforward : %d", g_fwTest);
}

public void OnTakeDamage(int victim, int attacker, int inflictor, float damage, int damagetype)
{
	PrintToChatAll("Got OnTakeDamage %N %N %d %f %d", victim, attacker, inflictor, damage, damagetype);
}