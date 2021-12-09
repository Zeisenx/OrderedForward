
#if defined _forward_order_included_
  #endinput
#endif
#define _forward_order_included_

native void FO_AddForward(const char[] name, PrivateForward fw, KeyValues kv)
native void FO_AddPlugin(const char fwName[], Function func);

forward void FO_OnReady();
forward void FO_OnReadyPost();

public SharedPlugin __pl_forward_order = 
{
	name = "forward_order",
	file = "forward_order.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_forward_order_SetNTVOptional()
{
	MarkNativeAsOptional("FO_AddForward");
	MarkNativeAsOptional("FO_AddPlugin");
}
#endif
