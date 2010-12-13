package  
{
	import flash.display.Sprite;
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	$(CBI)* ...
	$(CBI)* @author eralp
	$(CBI)*/
	public class PixelTF extends Sprite 
	{
		private var _text:String ="";
		private var _tf:TextField;
		private var _widthf:Number = 300;
		private var _heightf:Number = 300;
		private var _fontSize:Number = 8;
		// [Embed(source="fonts/uni05_53.ttf",fontFamily="system",embedAsCFF="false")] protected var pixelFont:String;
		
		
		public function PixelTF() 
		{
			mouseEnabled = false;
			mouseChildren = false;
		}
		
		public function get text():String { return _text; }
		
		public function set text(value:String):void 
		{
			_text = value;
			make(_text);
		}
		
		public function get widthf():Number { return _widthf; }
		
		public function set widthf(value:Number):void 
		{
			_widthf = value;
			make(_text);
		}
		
		public function get heightf():Number { return _heightf; }
		
		public function set heightf(value:Number):void 
		{
			_heightf = value;
			make(_text);
		}
		
		public function get fontSize():Number { return _fontSize; }
		
		public function set fontSize(value:Number):void 
		{
			_fontSize = value;
			make(_text);
		}
		
		protected function make(text:String):void
		{
			try {
				removeChild(_tf);
				//delete _tf;
			}catch (e:Error) { };
			
			_tf = new TextField();
			//_tf.width = _widthf;
			//_tf.height = _heightf;
			//_tf.multiline = true;
			//_tf.wordWrap = true;
			_tf.selectable = false;
			_tf.embedFonts = true;
			_tf.autoSize = TextFieldAutoSize.LEFT;
			
			_tf.antiAliasType = AntiAliasType.NORMAL;
			_tf.gridFitType = GridFitType.PIXEL;
			_tf.defaultTextFormat = new TextFormat("system", _fontSize, 0x000000,true,null,null,null,null,TextFormatAlign.LEFT);
			_tf.text = _text;
			addChild(_tf);
			this.x = Math.round(this.x);
			this.y = Math.round(this.y);
		}
		
	}

}