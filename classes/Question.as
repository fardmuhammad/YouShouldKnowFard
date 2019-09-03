package  
{
	import com.greensock.loading.MP3Loader;
	import com.greensock.loading.VideoLoader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Fard Muhammad
	 */
	public class Question extends MovieClip
	{
		public static const QREADY:String = "qready";
		public static const FREADY:String = "fready";
		protected var _qData:Object
		//protected var isAcceptingInput:Boolean = false;
		protected var _command:JackCommand = JackCommand.getInstance();
		protected var _model:JackModel = JackModel.getInstance();
		public var videoLoader:MovieClip;
		protected var vid:VideoLoader;
		protected var bgMusic:MP3Loader;
		protected var bgTheme:uint;
		
		public function Question() 
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		protected function init(e:Event) {
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		protected function setButtons(e:Event = null) {
			stage.focus = stage;
			_command.addEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
		}
		
		protected function unsetButtons(e:Event = null) {
			_command.removeEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
		}
		
		public function initData(qData:Object) {
			//OVERWRITTEN IN SUBCLASSES
		}
		
		protected function fitToArea(t:TextField, minSize:Number = 14) {
			var tf:TextFormat = t.getTextFormat();
			var size = tf.size;
			while (t.maxScrollV > 1 && size > minSize) {
				size--;
				tf.size = size;
				t.setTextFormat(tf);
			}
		}
		
		protected function keyPressed(k:KeyboardEvent) {
			//OVERWRITTEN IN SUBCLASSES
		}
		
		protected function right () {
			_command.rightAnswer();
		}
		
		protected function wrong() {
			_command.wrongAnswer();
		}
		
	}

}