package  
{
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.LoaderMax;
	import com.greensock.loading.SWFLoader;
	import com.greensock.TweenLite;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author Fard Muhammad
	 */
	public class PreLoad extends MovieClip
	{
		private var gameLoader:SWFLoader;
		private var mondoLoader:LoaderMax;
		public var game:MovieClip;
		private var currentLoad:Number = 0;
		
		public function PreLoad() 
		{
			border.mouseEnabled = false;
			introScreen.startGameButton.alpha = 0;
			introScreen.startGameButton.visible = false;

			gameLoader = new SWFLoader("game.swf", {name:"Main", estimatedBytes:6300000} );
			
			gameLoader.addEventListener(LoaderEvent.PROGRESS, update);
			gameLoader.addEventListener(LoaderEvent.COMPLETE, onButton);
			gameLoader.load();
		}
		
		private function update(l:LoaderEvent) {
			//trace (gameLoader.bytesLoaded / gameLoader.bytesTotal);
			
			var perc:String = String( Math.floor ( (gameLoader.bytesLoaded / gameLoader.bytesTotal) * 100));
			//if (Number(gameLoader.bytesLoaded / gameLoader.bytesTotal) - currentLoad < 50) {
			if (gameLoader.bytesLoaded / gameLoader.bytesTotal < .98) introScreen.loadingNumbers.text = perc + "%";
			//}
			//currentLoad = gameLoader.bytesLoaded / gameLoader.bytesTotal;
		}
		
		private function onButton(l:LoaderEvent) {
			//trace(l.target.content);
			introScreen.loadingNumbers.text = "100%"
			addChildAt(l.target.content, 0);
			TweenLite.to(introScreen.startGameButton, .5, { alpha:1, visible:true, onComplete:buttonON } );
		}
		
		private function buttonON() {
			introScreen.startGameButton.addEventListener(MouseEvent.CLICK, startGame);
			introScreen.startGameButton.addEventListener(MouseEvent.ROLL_OVER, scaleButton);
			introScreen.startGameButton.addEventListener(MouseEvent.ROLL_OUT, scaleButton);
		}
		
		private function scaleButton(m:MouseEvent) {
			var scaleN:Number = (m.type == MouseEvent.ROLL_OVER) ? 1.1 : 1;
				TweenLite.killTweensOf(introScreen.startGameButton);
				TweenLite.to(introScreen.startGameButton, .2, { scaleX: scaleN, scaleY:scaleN } );
		}
		
		private function startGame(m:MouseEvent) {
			TweenLite.killTweensOf(introScreen.startGameButton);
			TweenLite.to(introScreen, .6, { alpha:0, visible:false, onComplete:kill } );
		}
		
		private function kill() {
			stage.dispatchEvent(new Event("KILLLOADING"));
			removeChild(introScreen);
		}
		
	}

}