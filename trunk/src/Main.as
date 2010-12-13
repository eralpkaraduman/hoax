package 
{
	import com.bit101.components.CheckBox;
	import com.bit101.components.InputText;
	import com.bit101.components.PushButton;
	import com.bit101.components.Text;
	import com.swfjunkie.tweetr.*;
	import com.swfjunkie.tweetr.oauth.events.OAuthEvent;
	import com.swfjunkie.tweetr.oauth.OAuth;
	import flash.data.EncryptedLocalStore;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Rectangle;
	import flash.html.HTMLLoader;
	import flash.net.URLRequest;
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.ByteArray;
	import org.bytearray.gif.player.GIFPlayer;
	import states.ContactListState;
	import states.ReckognisedState;
	
	
	/**
	$(CBI)* ...
	$(CBI)* @author eralp
	$(CBI)*/
	public class Main extends Sprite 
	{
		public var lastOauth:OAuth;
		private var twitter:Tweetr;
		private var htmlLoader:HTMLLoader;
		private var oauth:OAuth;
		private var DMInput:InputText;
		private var btnSend:PushButton;
		private var authState_sprite:Sprite = null;
		private var stateContainerSprite:Sprite;
		public const appW:Number = 320;
		public const appH:Number = 480;
		private var currentStateSprite:Sprite;
		private var rememberOAuthFlag:Boolean = true;
		private var buddiesState_sprite:Sprite = null;
		private var reckognizedState_sprite:Sprite = null;
		private var _lastUserID:String;
		[Embed(source="fonts/uni05_53.ttf",fontFamily="system",embedAsCFF="false")] protected var pixelFont:String;
		
		private static var _instance:Main;
		private var contactListState_sprite:Sprite = null;
		public static function get instance():Main {return _instance;}
		
		public function Main():void 
		{
			_instance = this;
			
			stage.scaleMode = "noScale";
            stage.align = "TL";
			stateContainerSprite = new Sprite();
			addChild(stateContainerSprite);
			
			twitter = new Tweetr();
			
			twitter.serviceHost = "http://tweetr.swfjunkie.com/proxy";
			
			//DMInput.enabled = false;
			//btnSend.enabled = false;
			
			// check if authorized already ?
			
			// begin
			checkLocalSavedAuth();
			
			//if(!authorized)
			//authorize();
			// begin(); // extract from handleOAuthEvent()
		}
		
		private function checkLocalSavedAuth():void 
		{
			if (loadAuth()) {
				makeReckognizedState();
			}else {
				makeAuthState();
			}
		}
		
		private function onRememberCheck_authState(e:MouseEvent):void
		{
			rememberOAuthFlag = e.target["selected"];
			//trace("rememberOAuthFlag", rememberOAuthFlag);
			if (rememberOAuthFlag) {
				e.target["label"] = "Will Remember";
			}else {
				e.target["label"] = "Will Not Remember";
			}
		}
		
		private function onAuthBTN_authState(e:MouseEvent):void
		{
			trace("clicky");
			makeBuddiesState();
		}
		
		/////////////////////////////////////
		/////////////   STATES   ////////////
		/////////////////////////////////////
		
		private function makeAuthState():void
		{
			if(currentStateSprite)stateContainerSprite.removeChild(currentStateSprite);
			if (!authState_sprite) {
				authState_sprite = new Sprite();
				
				
				var tf:PixelTF = new PixelTF();
				tf.text = "You are not authorized.\nClick authorize below\nto do this now";
				tf.widthf = appW - 50;
				tf.fontSize = 16;
				tf.x = 25;
				tf.y = 25 + 40 + 25;
				tf.heightf =170;
				authState_sprite.addChild(tf);
				
				var tfh:PixelTF = new PixelTF();
				tfh.text = "HOAX";
				tfh.fontSize = 80;
				tfh.x = 25;
				tfh.y = -35 +25;
				tfh.widthf = appW - 50;
				authState_sprite.addChild(tfh);
				
				var authBTN:PushButton = new PushButton(authState_sprite,25, tf.heightf + 10, "AUTHORIZE", onAuthBTN_authState);
				var rememberCheck:CheckBox = new CheckBox(authState_sprite, 25, authBTN.y + authBTN.height + 5, "Will Remember", onRememberCheck_authState);
				rememberCheck.selected = true;
			}
			currentStateSprite = authState_sprite;
			stateContainerSprite.addChild(authState_sprite);
		}
		
		private function makeReckognizedState():void
		{
			// temp part 1
			if(currentStateSprite)stateContainerSprite.removeChild(currentStateSprite);
			if (!reckognizedState_sprite) {
				reckognizedState_sprite = new Sprite();
			// [x] temp part 1
			
			// logo
			var tfh:PixelTF = new PixelTF();
			tfh.text = "HOAX";
			tfh.fontSize = 80;
			tfh.x = 25;
			tfh.y = -35 +25;
			tfh.widthf = appW - 50;
			
			reckognizedState_sprite.addChild(tfh);
			var profilePicLoader:Loader = new Loader();
			profilePicLoader.x = 27;
			profilePicLoader.y = 100;
			reckognizedState_sprite.addChild(profilePicLoader);
			var stateObject:ReckognisedState = new ReckognisedState();
			
			var tfScreenName:PixelTF = new PixelTF();
			tfScreenName.x = 27 + 50;
			tfScreenName.fontSize = 16;
			tfScreenName.y = 100 - 8;
			reckognizedState_sprite.addChild(tfScreenName);
			
			var tfName:PixelTF = new PixelTF();
			tfName.x = 27 + 50;
			tfName.fontSize = 8;
			tfName.y = 122 - 8;
			reckognizedState_sprite.addChild(tfName);
			
			stateObject.api = twitter;
			stateObject.profilePicLoader = profilePicLoader;
			stateObject.screenNameDisplayTF = tfScreenName;
			stateObject.nameDisplayTF = tfName;
			
			var btnDeleteAuth:PushButton = new PushButton(reckognizedState_sprite, 10, 10, "Delete Saved Authorization", deleteAuthHandler);
			btnDeleteAuth.width = 150;
			btnDeleteAuth.x = 27;
			btnDeleteAuth.y = 154;
			
			var btnContactList:PushButton = new PushButton(reckognizedState_sprite,27,200,"Contact List",makeContactListState)
			btnContactList.width = 70;
			btnContactList.height = 70;
			
			stateObject.init();
			
			// temp part 2
			}
			currentStateSprite = reckognizedState_sprite;
			stateContainerSprite.addChild(reckognizedState_sprite);
			// [x] temp part 2
		}
		
		private function makeContactListState(e:MouseEvent):void
		{
			// temp part 1
			if(currentStateSprite)stateContainerSprite.removeChild(currentStateSprite);
			if (!contactListState_sprite) {
				contactListState_sprite = new Sprite();
			// [x] temp part 1
			
			var stateObject:ContactListState = new ContactListState();
			//stateObject.api = twitter;
			stateObject.init();
			stateContainerSprite.addChild(stateObject);
			
			// temp part 2
			}
			currentStateSprite = contactListState_sprite;
			stateContainerSprite.addChild(contactListState_sprite);
			// [x] temp part 2
		}
		
		private function makeBuddiesState():void
		{
			// temp part 1
			if(currentStateSprite)stateContainerSprite.removeChild(currentStateSprite);
			if (!buddiesState_sprite) {
				buddiesState_sprite = new Sprite();
			// [x] temp part 1
			
			stage.nativeWindow.width = 780;
			stage.nativeWindow.height = 500;
			var tf:PixelTF = new PixelTF();
			tf.text = " Wait for the twitter authorization page to load, than enter credentials than click 'Allow'.";
			tf.heightf = 25;
			tf.widthf = 780;
			tf.y = -2;
			tf.fontSize = 8*2;
			var bgSpr:Sprite = new Sprite();
			bgSpr.graphics.lineStyle(NaN, 0, 0);
			bgSpr.graphics.beginFill(0x9d9d9d, 0.5);
			bgSpr.graphics.drawRect(0, 0, 780, 25);
			
			if (!htmlLoader) { htmlLoader = new HTMLLoader(); }
			htmlLoader.width = 780;
			htmlLoader.height = 500;
			
			/*
			var gifAnim:GIFPlayer= new GIFPlayer(true);
			gifAnim.load(new URLRequest("gfx/idle.gif"));
			buddiesState_sprite.addChild(gifAnim);
			*/
			
			buddiesState_sprite.addChild(htmlLoader);
			
			buddiesState_sprite.addChild(bgSpr);
			buddiesState_sprite.addChild(tf);
			
			authorize();
			
			
			// temp part 2
			}
			currentStateSprite = buddiesState_sprite;
			stateContainerSprite.addChild(buddiesState_sprite);
			// [x] temp part 2
			
		}
		
		private function makeUI():void
		{
			/*
			var btnDeleteAuth:PushButton = new PushButton(this, 10, 10, "Delete Saved Auth", deleteAuthHandler);
			DMInput = new InputText(this, btnDeleteAuth.x + btnDeleteAuth.width + 10, 10);
			btnSend = new PushButton(this, DMInput.x + DMInput.width + 10, 10, "Send", sendBtnHandler);
			*/
		}
		
		private function sendBtnHandler(e:MouseEvent):void
		{
			sendDM();
		}
		
		private function deleteAuthHandler(e:MouseEvent):void
		{
			deleteAuthSave();
			//this.stage.nativeWindow.close();
			checkLocalSavedAuth();
		}
		
		private function deleteAuthSave():void 
		{
			var file:File = File.applicationStorageDirectory.resolvePath("oauth.asobj");
			file.deleteFile();
		}
		
		
		private function authorize():void 
		{
			oauth = new OAuth();
			oauth.consumerKey = "zt26bzwD0twgQ3jGLcis1A";
			oauth.consumerSecret = "Ozx5lKL6YgMwap1lT1RRnEJ0fToyfHg3KRHnWZtk";
			oauth.callbackURL = "http://godstroke.com/hoax/index.html";
			oauth.pinlessAuth = true;
			oauth.addEventListener(OAuthEvent.COMPLETE, handleOAuthEvent);
			oauth.addEventListener(OAuthEvent.ERROR, handleOAuthEvent);
			//var rect:Rectangle = new Rectangle(50, 50, 780, 500);
			//htmllLoader = HTMLLoader.createRootWindow(true, null, true, rect);
			oauth.htmlLoader = htmlLoader;
			oauth.getAuthorizationRequest();
		}
		
		
		private function handleOAuthEvent(e:OAuthEvent):void 
		{
			if (e.type == OAuthEvent.COMPLETE) {
				
				//htmllLoader.stage.nativeWindow.close();
				lastOauth = oauth;
				twitter.oAuth = oauth;
				if(rememberOAuthFlag)saveAuth(oauth);
				
				
				
				
				stage.nativeWindow.width = appW;
				stage.nativeWindow.height = appH;
				
				//checkLocalSavedAuth();
				makeReckognizedState();
				
			}else {
				trace("ERROR " + e.text);
			}
		}
		
		private function sendDM():void
		{
			if(oauth){
				twitter.sendDirectMessage(DMInput.text, "godstroke");
			}else {
				throw new Error("NO oauth, did not send DM");
			}
		}
		
		// save oauth
		private function saveAuth(oauth:OAuth):void {
			var object:Object = new Object();//create an object to store
			
			// save
			object.consumerKey = oauth.consumerKey;
			object.consumerSecret = oauth.consumerSecret;
			object.htmlLoader = oauth.htmlLoader;
			object.oauthToken = oauth.oauthToken;
			object.oauthTokenSecret = oauth.oauthTokenSecret;
			object.pinlessAuth = oauth.pinlessAuth;
			object.callbackURL = oauth.callbackURL;
			object.serviceHost = oauth.serviceHost;
			object.userId = oauth.userId;
			object.username = oauth.username;
			
			var file:File = File.applicationStorageDirectory.resolvePath("oauth.asobj");
			if (file.exists)file.deleteFile();
			var fileStream:FileStream = new FileStream(); //create a file stream
			fileStream.open(file, FileMode.WRITE);// and open the file for write
			fileStream.writeObject(object);//write the object to the file
			fileStream.close();
		}
		
		private function loadAuth():Boolean {
			//read the file
			var file:File = File.applicationStorageDirectory.resolvePath("oauth.asobj");
			if (!file.exists) {
				trace("There is no object saved!");
				return false;
			}
			//create a file stream and open it for reading
			var fileStream:FileStream = new FileStream();
			fileStream.open(file, FileMode.READ);
			var object:Object = fileStream.readObject(); //read the object
			//trace("The text member has this value: " + object.value);
			
			var _oauth:OAuth = new OAuth();
			_oauth.consumerKey = object.consumerKey;
			_oauth.consumerSecret = object.consumerSecret;
			_oauth.htmlLoader = object.htmlLoader;
			_oauth.oauthToken = object.oauthToken;
			_oauth.oauthTokenSecret = object.oauthTokenSecret;
			_oauth.pinlessAuth = object.pinlessAuth;
			_oauth.callbackURL = object.callbackURL;
			_oauth.serviceHost = object.serviceHost;
			_lastUserID = object.userId;
			//_oauth.userId = object.userId;
			_oauth.username = object.username;
			
			oauth = _oauth;
			lastOauth = oauth;
			twitter.oAuth = oauth;
			
			//trace(oauth);
			return true;
		}
		
		/**
		 * always use this to get userID, not oauth obj, this handles where to get it. (in case of saved.. stuff)
		 */
		public function get lastUserID():String { 
			if (oauth) {
				if (oauth.userId) {
					return oauth.userId;
				}else {
					return _lastUserID; 
				}
			}else {
				return _lastUserID; 
			}
			
			
		}
		
	}
}