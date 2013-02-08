package barmatz.comfy.facebook.errors
{
	public class JSError extends Error
	{
		public static const NO_APPLICATION_ID:uint = 1000,
							NO_EXTERNAL_INTERFACE:uint = 1001;
		
		public function JSError(message:*="", id:*=0)
		{
			super(message, id);
		}
	}
}