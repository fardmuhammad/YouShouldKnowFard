package  
{
	import com.greensock.events.LoaderEvent;
	import com.greensock.TweenLite;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.ui.Mouse;
	
	/**
	 * ...
	 * @author Fard Muhammad
	 */
	public class LoadingScreen extends MovieClip
	{
		static public const KILLLOADING:String = "killloading";
		
		private var _model:JackModel;
		public var startGameButton:SimpleButton;
		public var loadingNumbers:TextField;
		public function LoadingScreen() 
		{
			startGameButton.alpha = 0;
			startGameButton.visible = false;
			addEventListener(Event.ADDED_TO_STAGE, setup);
		}
		
		private function setup(e:Event) { 
			removeEventListener(Event.ADDED_TO_STAGE, setup);
			_model = JackModel.getInstance();
			_model.addEventListener(JackModel.LOADERREADY, loaderReady);
		}
		
		private function loaderReady(e:Event) {
			_model.removeEventListener(JackModel.LOADERREADY, loaderReady);
			_model.loader.addEventListener(LoaderEvent.CHILD_PROGRESS, progress);
			_model.loader.addEventListener(LoaderEvent.CHILD_COMPLETE, onDone);
		}
		
		private function progress(l:LoaderEvent) {
			var perc:String = String( Math.round ( (_model.loader.bytesLoaded / _model.loader.bytesTotal) * 100));
			loadingNumbers.text = perc + "%";
		}
		
		private function onDone(l:LoaderEvent) {
			TweenLite.to(startGameButton, .5, { alpha:1, visible:true, onComplete:buttonON } );
		}
		
		private function buttonON() {
			startGameButton.addEventListener(MouseEvent.CLICK, startGame);
			startGameButton.addEventListener(MouseEvent.ROLL_OVER, scaleButton);
			startGameButton.addEventListener(MouseEvent.ROLL_OUT, scaleButton);
		}
		
		private function scaleButton(m:MouseEvent) {
			var scaleN:Number = (m.type == MouseEvent.ROLL_OVER) ? 1.1 : 1;
				TweenLite.killTweensOf(startGameButton);
				TweenLite.to(startGameButton, .2, { scaleX: scaleN, scaleY:scaleN } );
		}
		
		private function startGame(m:MouseEvent) {
			TweenLite.killTweensOf(startGameButton);
			TweenLite.to(this, .6, { alpha:0, visible:false, onComplete:kill } );
		}
		
		private function kill() {
			dispatchEvent(new Event(KILLLOADING))
		}
		
	}

}