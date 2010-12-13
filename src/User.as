package  
{
	import flash.net.URLRequest;
	/**
	$(CBI)* ...
	$(CBI)* @author eralp
	$(CBI)*/
	public class User 
	{
		private var _userID:String;
		
		private var _xml:XML;
		
		public function User(xml:XML) 
		{
			_xml = xml;
			
		}
		
		public function get profile_picture_url():URLRequest {
			var url:String = String(_xml.profile_image_url);
			var ureq:URLRequest = new URLRequest(url);
			return ureq; 
		}
		
		public function get screen_name():String {
			return _xml.screen_name; 
		}
		
		public function get name():String {
			return _xml.name; 
		}
		
		public function get userID():String {
			return _xml.id; 
		}
		
		
	}

}