package org.assetloader
{
	
	
	import org.assetloader.AssetLoader;
	import org.assetloader.core.ILoader;
	import org.assetloader.base.Param;
	
	/**
	 * @author Asaf Kuller
	 */
	public class AssentLoaderPlus extends AssetLoader{

		
		public function AssentLoaderPlus(id : String = "PrimaryGroup")
		{
			super(id);
		}
		
		/**
		 * Inserts a loader at a particular position in the queue.
		 * the queue is a sorted loaders' ids array, the elements order is the oeder that the loader will start.
		 * The insert function will change the priorety parameter of the loader according to it's postion in the queue.
		 */
		public function insert(loader : ILoader , index:uint=999999999) : void
		{
			
			var BytesAndSignals:Boolean = true;
			
			if (index > _ids.length)
			{
				index = _ids.length;
			}

			if(hasLoader(loader.id))
			{
				//throw new AssetLoaderError(AssetLoaderError.ALREADY_CONTAINS_LOADER_WITH_ID(_id, loader.id));
				BytesAndSignals = false;
				var indexOfID:uint = _ids.indexOf(loader.id);
				
				if (indexOfID == index)
					return;
				else
					_ids.splice(_ids.indexOf(loader.id),1);
					_numLoaders = _ids.length;
			}
			else
				_loaders[loader.id] = loader;
			
			// if start was not called there aneed to sort id by priority
			if (!_invoked)
				sortIdsByPriority();
				
			// insert the loader idto the right postion in the ids array:
			_ids.splice(index, 0, loader.id)		
			
			// set the a proper priorety value to the loader postion in the queue, the sorted ids array
			// trying to keep the loader previus value for priorety
			// you could create a much cleaner code by: 
			// loader.setParam(Param.PRIORITY, getLoader[_ids[index].getParam(Param.PRIORITY)]
			// before inserting the loader to _ids array
			
			var largerPrio:int;
			var smallerPrio:int;
			var currentPrio:int = loader.getParam(Param.PRIORITY);
			
			if(index == 0)
			{
				smallerPrio = getLoader(_ids[1]).getParam(Param.PRIORITY);
				if (currentPrio <= smallerPrio)
					loader.setParam(Param.PRIORITY, smallerPrio + 1);
			}
			else if(index == _ids.length-1 )
			{
				largerPrio = getLoader(_ids[_ids.length-2]).getParam(Param.PRIORITY);
				if (currentPrio >= largerPrio)
					loader.setParam(Param.PRIORITY, largerPrio - 1);
			}
			else
			{
				smallerPrio = getLoader(_ids[index+1]).getParam(Param.PRIORITY);
				largerPrio = getLoader(_ids[index-1]).getParam(Param.PRIORITY);
				if (!(currentPrio > smallerPrio && currentPrio < largerPrio) )
					loader.setParam(Param.PRIORITY, Math.round((smallerPrio+largerPrio)/2));
			}
			
			
			_numLoaders = _ids.length;
			
			if(BytesAndSignals)
			{
				
				loader.onStart.add(start_handler);
				updateTotalBytes();
				loader.onAddedToParent.dispatch(loader, this);
			}
			
		}
		
		/**
		 * Appends a loader to the end of the queue.
		 * 
		 */
		public function append(loader:ILoader):void
		{
			insert(loader, _ids.length);
		}
		
		/**
		 * Prepends a loader at the beginning of the queue (<code>append()</code> adds the loader to the end whereas <code>prepend()</code> adds it to the beginning).
		 * 
		 */
		public function prepend(loader:ILoader):void
		{
			insert(loader, 0);
		}
		
		public function prioritize(loaderID:String,loadNow:Boolean=true):void
		{
			
			var StartNow:Boolean;
			var loader:ILoader;
			if(hasLoader(loaderID))
			{
				loader = getLoader(loaderID);
				StartNow  = loadNow && !loader.inProgress;
				
				if(StartNow)
					this.stop();
				insert(loader, 0);
				if(StartNow)
					this.start();

			}
			
		}

	}
	
}
