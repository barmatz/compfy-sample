package  org.assetloader
{
	import org.assetloader.base.StatsMonitor;
	import org.assetloader.signals.ErrorSignal;
	import org.assetloader.signals.LoaderSignal;
	import org.assetloader.core.ILoader;
	
	public class StatsMonitorPlus extends StatsMonitor{
		
		protected var _onChildError : ErrorSignal;
		protected var _onChildComplete :LoaderSignal;
		
		public function StatsMonitorPlus() 
		{
			super();
			_onChildError = new ErrorSignal();
			_onChildComplete = new LoaderSignal();
			
		}
		
		public function hasLoader(loader : ILoader) :Boolean
		{
			if (_loaders.indexOf(loader) == -1)
				return false;
			return true;
		}
		
		
		/**
		 * Removes all internal listeners and clears the monitoring list.
		 * 
		 * <p>Note: After calling destroy, this instance of StatsMonitor is still usable.
		 * Simply rebuild your monitor list via the add() method.</p>
		*/
		override public function destroy() : void
		{
			super.destroy()
			trace("destroy in plus")
			_onChildError.removeAll();
			_onChildComplete.removeAll();
			/*
			for each(var loader : ILoader in _loaders)
			{
				removeListener(loader);
			}

			_loaders = [];
			_numLoaders = 0;
			_numComplete = 0;

			_onOpen.removeAll();
			_onProgress.removeAll();
			_onComplete.removeAll();
			*/
		}
		
		/**
		 * @private
		 */
		override protected function addListener(loader : ILoader) : void
		{
			loader.onStart.add(start_handler);
			loader.onOpen.add(open_handler);
			loader.onProgress.add(progress_handler);
			loader.onComplete.add(complete_handler);
			loader.onError.add(error_handler);	
		}
	
		/**
		 * @private
		 */
		override protected function removeListener(loader : ILoader) : void
		{
			loader.onStart.remove(start_handler);
			loader.onOpen.remove(open_handler);
			loader.onProgress.remove(progress_handler);
			loader.onComplete.remove(complete_handler);
			loader.onError.remove(error_handler);	
		}
		
		
		protected function error_handler(signal : ErrorSignal) : void
		{
			_onChildError.dispatch()
		}
		
		/**
		 * @private
		 */
		override protected function complete_handler(signal : LoaderSignal, payload : *) : void
		{
			super.complete_handler(signal, payload )
			_onChildComplete.dispatch()
		}
		
		
		//-------------------------------------------------------------------------
		// Getters and Setters
		//-------------------------------------------------------------------------
		
		public function get Loaders():Array {return _loaders;}
		public function get onChildError() : ErrorSignal {return _onChildError;}
		public function get onChildComplete() :LoaderSignal{return _onChildComplete;}
		
	}
}
