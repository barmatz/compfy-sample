package barmatz.comfy.facebook
{
	import flash.errors.IllegalOperationError;

	public class FacebookStatus
	{
		public static const CONNECTED:String = "connected",
							UNKNOWN:String = "unknown";
		
		public function FacebookStatus()
		{
			throw new IllegalOperationError("This is a static class and should not be initiated.");
		}
	}
}