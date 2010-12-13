package states 
{
	import com.bit101.charts.BarChart;
	import com.bit101.components.InputText;
	import com.bit101.components.Slider;
	import com.bit101.components.VScrollBar;
	import com.bit101.components.VSlider;
	import com.swfjunkie.tweetr.events.TweetEvent;
	import com.swfjunkie.tweetr.Tweetr;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	import ui.ContactRow;
	/**
	$(CBI)* ...
	$(CBI)* @author eralp
	$(CBI)*/
	public class ContactListState extends Sprite
	{
		private var v_friendIDS:Vector.<String> = new Vector.<String>();
		private var v_followerIDS:Vector.<String> = new Vector.<String>();
		private var v_chatableIDS:Vector.<String> = new Vector.<String>();
		private var v_chatableRows:Vector.<ContactRow> = new Vector.<ContactRow>();
		private var chatableRowContainer:Sprite = new Sprite();
		
		public var api:Tweetr;
		private var slider:VSlider;
		private var searchboxH:Number = 16;
		private var searchConatiner:Sprite;
		private var searchInput:InputText;
		private var vec_friendsData:Vector.<User>;
		private var vec_searchResult:Vector.<User> = new Vector.<User>();
		
		public function ContactListState() 
		{
			
		}
		
		public function init():void {
			api = new Tweetr();
			api.oAuth = Main.instance.lastOauth;
			loadContactList();
		}
		
		private function loadContactList():void {
			api.addEventListener(TweetEvent.COMPLETE, onApiComplete_getFriends);
			api.getFriendIds(Main.instance.lastUserID);
		}
		
		private function onApiComplete_getFriends(e:TweetEvent):void 
		{
			api.removeEventListener(TweetEvent.COMPLETE, onApiComplete_getFriends);
			for each( var x:XML in XML(e.data).id) {
				v_friendIDS.push(String(x));
			}
			loadContactList_contd();
		}
		
		//--
		
		private function loadContactList_contd():void 
		{
			api.addEventListener(TweetEvent.COMPLETE, onApiComplete_getFollowers);
			api.getFollowerIds(Main.instance.lastUserID);
		}
		
		private function onApiComplete_getFollowers(e:TweetEvent):void 
		{
			api.removeEventListener(TweetEvent.COMPLETE, onApiComplete_getFollowers);
			
			for each( var x:XML in XML(e.data).id) {
				v_followerIDS.push(String(x));
			}
			
			findChatables();
		}
		
		//--
		
		private function findChatables():void
		{
			for each(var fr_id:String in v_friendIDS) {
				for each(var fo_id:String in v_followerIDS) {
					if (fr_id == fo_id) {
						v_chatableIDS.push(fr_id);
						break;
					}
				}
			}
			
			displayChatables();
			
		}
		
		private function displayChatables():void
		{
			chatableRowContainer.y = searchboxH; 
			
			var i:uint = 0;
			for each(var cha_id:String in v_chatableIDS) {
				var row:ContactRow = new ContactRow(chatableRowContainer, i, cha_id,api);
				chatableRowContainer.addChild(row);
				v_chatableRows.push(row);
				i++;
				
				//if (i >= 1) break; // REMOVE THIS, TEMPORARY.
			}
			addChild(chatableRowContainer);
			slider = new VSlider(this, 0, 0, scrollHandler);
			
			slider.y = searchboxH;
			slider.height = Main.instance.appH - searchboxH;
			slider.width = Main.instance.appW - (300);
			slider.x = 300;
			slider.maximum = 0;
			slider.minimum = -1*(v_chatableIDS.length * 49 - (Main.instance.appH - searchboxH));
			//slider.value = minimum;
			slider.value = slider.maximum;
			
			scrollHandler(null);
			loadRowsOnScreen(null);
			//slider.val = 0;
			
			
			makeSearchBox();
			
			var t:Timer = new Timer(5000);
			t.addEventListener(TimerEvent.TIMER, loadRowsOnScreen);
			t.start();
		}
		
		private function makeSearchBox():void
		{
			searchConatiner = new Sprite();
			
			var srchlabel:PixelTF = new PixelTF();
			srchlabel.text = "Search";
			srchlabel.fontSize = 16;
			searchConatiner.addChild(srchlabel);
			srchlabel.y = -7;
			
			searchInput = new InputText(searchConatiner, 70, 0, "", onSearch);
			searchInput.enabled = false;
			searchInput.width = Main.instance.appW - searchInput.x;
			searchInput.height = searchboxH;
			
			searchConatiner.graphics.lineStyle(0, 0, 0);
			searchConatiner.graphics.beginFill(0xffffff, 1);
			searchConatiner.graphics.drawRect(0, 0, (Main.instance.appW - searchInput.x), searchboxH);
			searchConatiner.graphics.endFill();
			
			addChild(searchConatiner);
			
			var _api:Tweetr = new Tweetr();
			_api.oAuth = Main.instance.lastOauth;
			_api.addEventListener(TweetEvent.COMPLETE, onFriendsDataLoaded);
			_api.getFriends(Main.instance.lastUserID);
			
		}
		
		private function onFriendsDataLoaded(e:TweetEvent):void 
		{
			Tweetr(e.target).removeEventListener(TweetEvent.COMPLETE, onFriendsDataLoaded);
			trace("onFriendsDataLoaded");

			vec_friendsData = new Vector.<User>(/*XML(e.data).user.length(),true*/); 
			for each(var x:XML in XML(e.data).user) {
				var user:User = new User(x);
				vec_friendsData.push(user);
			}
			searchInput.enabled = true;
			
		}
		
		private function onSearch(e:Event):void
		{
			var key:String = searchInput.text;
			vec_searchResult = new Vector.<User>();
			
			if (key.length <= 0) {
				vec_searchResult = vec_friendsData;
				displayAllResult();
				return; /* ! */
			}
			///////////////////
			
			for (var i:Number = 0; i < vec_friendsData.length ; i++ ) {
				if (vec_friendsData[i].name.indexOf(key) >= 0 || vec_friendsData[i].screen_name.indexOf(key) >= 0) {
						vec_searchResult.push(vec_friendsData[i]);
				}
			}
			
			displaySearchResult();
			
		}
		
		private function displayAllResult():void
		{
			var i:uint = 0;
			for each(var r:ContactRow in v_chatableRows) {
				r.changeIndexTo(i);
				i++;
			}
		}
		
		private function displaySearchResult():void
		{
			var i:uint = 0;
			var j_k:uint = 0;
			//var j_e:uint = -1;
			
			//var v_unearched:Vector.<ContactRow> = new Vector.<ContactRow>();
			//var v_searched:Vector.<ContactRow> = new Vector.<ContactRow>();
			for each(var r:ContactRow in v_chatableRows) {
				//for each(var u:User in vec_searchResult) {
				var j:int = j_k;
				for (; j <vec_searchResult.length ; j++) 
				{
					//if (j_e > -1 && r.userID == j_e) {
						//
					//}
					
					if (vec_searchResult[j].userID == r.userID) {
						//var r_indx_tmp:uint = r.index;
						//j_e = r.userID;
						var oldIndex:uint = r.changeIndexTo(j);
 						v_chatableRows[j].changeIndexTo(oldIndex);
						//j_k = j+1; // dont search frm the start
						//break;
					}
				}
				i++
			}
			
			//chatableRowContainer.y = searchboxH; 
			//
			//var i:uint = 0;
			//for each(var cha_id:String in v_chatableIDS) {
				//var row:ContactRow = new ContactRow(chatableRowContainer, i, cha_id,api);
				//chatableRowContainer.addChild(row);
				//v_chatableRows.push(row);
				//i++;
				//
				//if (i >= 1) break; // REMOVE THIS, TEMPORARY.
			//}
			//addChild(chatableRowContainer);
			//slider = new VSlider(this, 0, 0, scrollHandler);
			//
			//slider.y = searchboxH;
			//slider.height = Main.instance.appH - searchboxH;
			//slider.width = Main.instance.appW - (300);
			//slider.x = 300;
			//slider.maximum = 0;
			//slider.minimum = -1*(v_chatableIDS.length * 49 - (Main.instance.appH - searchboxH));
			//slider.value = minimum;
			//slider.value = slider.maximum;
			//
			//scrollHandler(null);
			//loadRowsOnScreen(null);
			//slider.val = 0;
			//
			//
			//makeSearchBox();
			//
			//var t:Timer = new Timer(5000);
			//t.addEventListener(TimerEvent.TIMER, loadRowsOnScreen);
			//t.start();
		}
		
		private function scrollHandler(e:Event):void
		{
			chatableRowContainer.y = (Math.round(slider.value)) + searchboxH;
		}
		
		private function loadRowsOnScreen(e:TimerEvent):void 
		{
			for each(var r:ContactRow in v_chatableRows) {
				var screenXY:Point = new Point(r.x + chatableRowContainer.x, r.y + chatableRowContainer.y);
				if (screenXY.y >= searchboxH && screenXY.y <= (Main.instance.appH - searchboxH)) {
					r.loadIfNotLoaded();
				}
			}
		}
		
		
		
		
		
	}

}