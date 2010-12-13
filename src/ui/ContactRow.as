package ui 
{
	import com.swfjunkie.tweetr.events.TweetEvent;
	import com.swfjunkie.tweetr.Tweetr;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.DRMAuthenticationCompleteEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.geom.Point;
	import flash.net.URLRequest;
	/**
	$(CBI)* ...
	$(CBI)* @author eralp
	$(CBI)*/
	public class ContactRow extends Sprite
	{
		private var _parent:Sprite;
		private var _index:uint;
		private var _profilePicPath:String;
		private var _alias:String;
		private var _name:String;
		
		private var wh:Point = new Point(300,49);
		private var ppwh:Point = new Point(48,48);
		private var _userID:String;
		private var _api:Tweetr;
		private var pploader:Loader = new Loader();
		private var temp_pploader:Loader = new Loader();
		private var aliasTXT:PixelTF;
		private var nameTXT:PixelTF;
		private var _loaded:Boolean;
		
		public function ContactRow(parent:Sprite,index:uint,userID:String,api:Tweetr) 
		{
			_api = api;
			_userID = userID;
			_index = index;
			_parent = parent;
			
			
			temp_pploader.load(new URLRequest(getRandomTempBuddy()));
			temp_pploader.x = Math.round( ppwh.x / 2 - 13 / 2);
			temp_pploader.y = Math.round(ppwh.y / 2 - 13 / 2);
			addChild(temp_pploader);
			
			//
			this.y = _index * wh.y;
			//
			_parent.addChild(this);
			//
			var ve_adjust:Number = -10;
			//
			aliasTXT = new PixelTF();
			aliasTXT.text = "...";
			aliasTXT.y = 0 + ve_adjust;
			aliasTXT.x = 53;
			aliasTXT.fontSize = 24;
			addChild(aliasTXT);
			//
			nameTXT = new PixelTF();
			nameTXT.text = userID;
			nameTXT.y = 30 + ve_adjust;
			nameTXT.x = 53;
			nameTXT.fontSize = 16;
			addChild(nameTXT);
			
			
			
			/*
			_profilePicPath = profilePicPath;
			_name = name;
			_alias = alias;
			*/
			//make();
			
			//draw
			graphics.lineStyle(0, 0x000000, 1);
			graphics.beginFill(0xffffff, 1);
			
			graphics.drawRect(0, 0, wh.x, wh.y);
			graphics.endFill();
			
			addEventListener(Event.ADDED_TO_STAGE, oats);
			
			alpha = .3;
		}
		
		private function oats(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, oats);
			
			
		}
		
		private function onCL(e:MouseEvent):void
		{
			trace("_loaded ", _loaded);
		}
		
		public function loadIfNotLoaded():void
		{
			if (!_loaded) {
				//trace("yes");
				getUserDetails();
			}
		}
		
		public function changeIndexTo(idx:uint):uint
		{
			var old_i:uint = _index;
			
			parent.addChild(this);
			_index = idx;
			this.y = _index * wh.y;
			
			return old_i;
		}
		
		private function getUserDetails():void
		{
			alpha = 1;
			
			_loaded = true;
			
			//api.
			var api:Tweetr = new Tweetr();
			api.oAuth = Main.instance.lastOauth;
			api.addEventListener(TweetEvent.COMPLETE, onAPI);
			api.getUserDetails(_userID);
			
			mouseChildren = false;
			buttonMode = true;
			pploader.addEventListener(MouseEvent.CLICK, onCL);
			
			//temp buddy
			getRandomTempBuddy();
		}
		
		private function onAPI(e:TweetEvent):void 
		{
			var u:User = new User(XML(e.data));
			_profilePicPath = u.profile_picture_url.url;
			_name = u.name;
			_alias = u.screen_name;
			
			make();
		}
		
		private function make():void 
		{
			pploader = new Loader();
			pploader.contentLoaderInfo.addEventListener(Event.COMPLETE, onPPLoaded);
			pploader.load(new URLRequest(_profilePicPath));
			pploader.x = pploader.y = 1;
			//pploader.width = 70;
			//pploader.height = 70;
			addChild(pploader);
			//
			aliasTXT.text = _alias;
			//
			nameTXT.text = _name;
		}
		
		private function onPPLoaded(e:Event):void 
		{
			if(pploader.width!=ppwh.x)pploader.width =ppwh.x;
			if(pploader.height!=ppwh.y)pploader.height = ppwh.y;
		}
		
		
		public function get userID():String { return _userID; }
		
		public function get index():uint { return _index; }
		
		private function getRandomTempBuddy():String {
			//var file:File = new File
			var dir:File = File.applicationDirectory;
			dir = dir.resolvePath("temp_buddy_icons");
			var imgs:Array = dir.getDirectoryListing();
			var rand_img:File = imgs[Math.round(Math.random() * (imgs.length - 1))];
			return rand_img.nativePath;
		}
		
	}

}