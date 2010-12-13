package states 
{
	import com.swfjunkie.tweetr.events.TweetEvent;
	import com.swfjunkie.tweetr.Tweetr;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.net.URLRequest;
	
	/**
	$(CBI)* ...
	$(CBI)* @author eralp
	$(CBI)*/
	public class ReckognisedState extends Sprite 
	{
		private var _profilePicLoader:Loader;
		public var profilePicURL:String;
		public var api:Tweetr;
		public var screenNameDisplayTF:PixelTF;
		public var nameDisplayTF:PixelTF;
		
		public function ReckognisedState() 
		{
			
		}
		
		public function init():void {
			trace("Main.instance.lastUserID", Main.instance.lastUserID);
			trace("--");
			api.addEventListener(TweetEvent.COMPLETE, onApiComplete);
			api.getUserDetails(Main.instance.lastUserID);
		}
		
		public function get profilePicLoader():Loader { return _profilePicLoader; }
		
		/**
		 * pass profilepic as Loader, it will automaticly start loading
		 */
		public function set profilePicLoader(value:Loader):void 
		{
			
			
			/*
			var ppicURL:String = profilePicURL;
			if (!ppicURL) {
				throw new Error("you must pass pic url before setting _profilePic");
			}
			_profilePic.load(ppicURL);
			*/
			_profilePicLoader = value;
		}
		
		private function onApiComplete(e:TweetEvent):void 
		{
			api.removeEventListener(TweetEvent.COMPLETE, onApiComplete);
			
			var user:User = new User(XML(e.data));
			_profilePicLoader.load(user.profile_picture_url);
			screenNameDisplayTF.text = user.screen_name;
			nameDisplayTF.text = user.name;
			//trace("TweetEvent ", e.data);
			//profilePicURL = String(XML(e.data).profile_image_url);
			//trace(  String(XML(e.data).profile_image_url)  )
			//_profilePic.load(new URLRequest(String(XML(e.data).profile_image_url)));
			
		}
		
	}

}