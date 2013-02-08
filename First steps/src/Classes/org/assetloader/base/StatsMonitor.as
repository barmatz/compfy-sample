package org.assetloader.base
{
	import org.assetloader.core.ILoadStats;
	import org.assetloader.core.ILoader;
	import org.assetloader.signals.LoaderSignal;
	import org.assetloader.signals.ProgressSignal;

	/**
	 * @author Matan Uberstein
	 * 
	 * Consolidates multiple ILoader's stats.
	 */
	public class StatsMonitor
	{
		protected var _loaders : Array;
		protected var _stats : ILoadStats;

		protected var _numLoaders : int;
		protected var _numComplete : int;

		protected var _onOpen : LoaderSignal;
		protected var _onProgress : ProgressSignal;
		protected var _onComplete : LoaderSignal;

		public function StatsMonitor()
		{
			_loaders = [];
			_stats = new LoaderStats();

			_onOpen = new LoaderSignal();
			_onProgress = new ProgressSignal();
			_onComplete = new LoaderSignal(ILoadStats);
		}

		/**
		 * Adds ILoader for monitoring.
		 * 
		 * @param loader Instance of ILoader or IAssetLoader.
		 * 
		 * @throws org.assetloader.base.AssetLoaderError ALREADY_CONTAINS_LOADER
		 */
		public function add(loader : ILoader) : void
		{
			if(_loaders.indexOf(loader) == -1)
			{
				addListener(loader);

				_loaders.push(loader);
				_numLoaders = _loaders.length;
			}
			else
				throw new AssetLoaderError(AssetLoaderError.ALREADY_CONTAINS_LOADER);
		}

		/**
		 * Removes ILoader from monitoring.
		 * 
		 * @param loader An instance of an ILoader already added.
		 * 
		 * @throws org.assetloader.base.AssetLoaderError DOESNT_CONTAIN_LOADER
		 */
		public function remove(loader : ILoader) : void
		{
			var index : int = _loaders.indexOf(loader);
			if(index != -1)
			{
				removeListener(loader);

				if(loader.loaded)
					_numComplete--;

				_loaders.splice(index, 1);
				_numLoaders = _loaders.length;
			}
			else
				throw new AssetLoaderError(AssetLoaderError.DOESNT_CONTAIN_LOADER);
		}

		/**
		 * Removes all internal listeners and clears the monitoring list.
		 * 
		 * <p>Note: After calling destroy, this instance of StatsMonitor is still usable.
		 * Simply rebuild your monitor list via the add() method.</p>
		 */
		public function destroy() : void
		{
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
		}

		/**
		 * @private
		 */
		protected function addListener(loader : ILoader) : void
		{
			loader.onStart.add(start_handler);
			loader.onOpen.add(open_handler);
			loader.onProgress.add(progress_handler);
			loader.onComplete.add(complete_handler);
		}

		/**
		 * @private
		 */
		protected function removeListener(loader : ILoader) : void
		{
			loader.onStart.remove(start_handler);
			loader.onOpen.remove(open_handler);
			loader.onProgress.remove(progress_handler);
			loader.onComplete.remove(complete_handler);
		}

		/**
		 * @private
		 */
		protected function start_handler(signal : LoaderSignal) : void
		{
			for each(var loader : ILoader in _loaders)
			{
				loader.onStart.remove(start_handler);
			}
			_stats.start();
		}

		/**
		 * @private
		 */
		protected function open_handler(signal : LoaderSignal) : void
		{
			_stats.open();
			_onOpen.dispatch(signal.loader);
		}

		/**
		 * @private
		 */
		protected function progress_handler(signal : ProgressSignal) : void
		{
			var bytesLoaded : uint;
			var bytesTotal : uint;
			for each(var loader : ILoader in _loaders)
			{
				bytesLoaded += loader.stats.bytesLoaded;
				bytesTotal += loader.stats.bytesTotal;
			}
			_stats.update(bytesLoaded, bytesTotal);

			_onProgress.dispatch(signal.loader, _stats.latency, _stats.speed, _stats.averageSpeed, _stats.progress, _stats.bytesLoaded, _stats.bytesTotal);
		}

		/**
		 * @private
		 */
		protected function complete_handler(signal : LoaderSignal, payload : *) : void
		{
			_numComplete++;
			if(_numComplete == _numLoaders)
			{
				_stats.done();
				_onComplete.dispatch(null, _stats);
			}
		}

		/**
		 * Get the overall stats of all the ILoaders in the monitoring list.
		 * 
		 * @return ILoadStats
		 */
		public function get stats() : ILoadStats
		{
			return _stats;
		}

		/**
		 * Dispatches each time a connection has been opend.
		 * 
		 * <p>HANDLER ARGUMENTS: (signal:<strong>LoaderSignal</strong>)</p>
		 * <ul>
		 *	 <li><strong>signal</strong> - The signal that dispatched.</li>
		 * </ul>
		 * 
		 * @see org.assetloader.signals.LoaderSignal
		 */
		public function get onOpen() : LoaderSignal
		{
			return _onOpen;
		}

		/**
		 * Dispatches when loading progress has been made.
		 * 
		 * <p>HANDLER ARGUMENTS: (signal:<strong>ProgressSignal</strong>)</p>
		 * <ul>
		 *	 <li><strong>signal</strong> - The signal that dispatched.</li>
		 * </ul>
		 * 
		 * @see org.assetloader.signals.ProgressSignal
		 */
		public function get onProgress() : ProgressSignal
		{
			return _onProgress;
		}

		/**
		 * Dispatches when the loading operations has completed.
		 * 
		 * <p>HANDLER ARGUMENTS: (signal:<strong>LoaderSignal</strong>, stats:<strong>ILoadStats</strong>)</p>
		 * <ul>
		 *	 <li><strong>signal</strong> - The signal that dispatched.</li>
		 *	 <li><strong>stats</strong> - Consolidated stats.</li>
		 * </ul>
		 * 
		 * @see org.assetloader.signals.LoaderSignal
		 */
		public function get onComplete() : LoaderSignal
		{
			return _onComplete;
		}

		/**
		 * Gets the amount of loaders added to the monitoring queue.
		 * 
		 * @return int
		 */
		public function get numLoaders() : int
		{
			return _numLoaders;
		}

		/**
		 * Gets the amount of loaders that have finished loading.
		 * 
		 * @return int
		 */
		public function get numComplete() : int
		{
			return _numComplete;
		}
	}
}
