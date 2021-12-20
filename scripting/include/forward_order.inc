
#if defined _forward_order_included_
  #endinput
#endif
#define _forward_order_included_

methodmap OrderForward __nullable__
{
	public native OrderForward(PrivateForward fw, const char[] keyName, KeyValues orderKV);
	
	property PrivateForward fw {
		public native get();
	}
	
	public native void RequestFunc(Function func);
}

native OrderForward FO_FindForward(const char[] keyName);

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
