package  
{
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.LoaderMax;
	import flash.display.MovieClip;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	/**
	 * ...
	 * @author Fard Muhammad
	 */
	public class JackCommand extends EventDispatcher
	{
		static public const UPDATESCORE:String = "updatescore";
		static public const PAUSE:String = "pause";
		static public const UNPAUSE:String = "unpause";
		static public const LOADNEXT:String = "loadnext";
		static public const CREATENEXTQ:String = "createnextq";
		static public const HIDESCORE:String = "hidescore";
		static public const SHOWSCORE:String = "showscore";
		static public const STARTQUESTION:String = "startquestion";
		
		//SINGLETON
		private var _model:JackModel

		public function JackCommand() 
		{
			_model = JackModel.getInstance();
		}

		private static var _inst:JackCommand;
		
		public static function getInstance():JackCommand {
			if (_inst == null) _inst = new JackCommand();
			return _inst;
		}
		
		public function keyStroke(k:KeyboardEvent) {
			//trace ("COMMAND: keystroke!");
			dispatchEvent(k.clone());
		}
		
		public function hideScore() {
			dispatchEvent(new Event(HIDESCORE));
		}
		
		public function showScore() {
			//trace("COMMAND: Show the score");
			dispatchEvent(new Event(SHOWSCORE));
		}
		
		public function startQuestion() {
			dispatchEvent(new Event(STARTQUESTION));
		}
		
		public function wrongAnswer() {
			_model.wrongAnswer();
			dispatchEvent(new Event(UPDATESCORE));
		}
		
		public function rightAnswer() {
			_model.rightAnswer();
			dispatchEvent(new Event(UPDATESCORE));
		}
		
		
		public function preLoadQuestion(qNum:Number) {
			trace ("preloading... " + qNum);
			if (qNum < _model.questionWhich.length)
			{
				dispatchEvent(new Event(CREATENEXTQ))
				var nextLoad:LoaderMax;
				if (!_model.questionWhich[qNum].final) {
					nextLoad = _model.getLoader("Q" + qNum);
					nextLoad.addEventListener(LoaderEvent.COMPLETE, qready);
					nextLoad.load();
				} else {
					nextLoad = _model.getLoader("FF");
					nextLoad.addEventListener(LoaderEvent.COMPLETE, fready);
					nextLoad.load();
				}
			/*} else if (qNum == -1) {
				//dispatchEvent(new Event(CREATEFINAL));
				var finalLoad:LoaderMax;
				finalLoad = _model.getLoader(_model.finalRound.name);
				finalLoad.addEventListener(LoaderEvent.COMPLETE, qready);
				finalLoad.load();*/
			}
		}
		
		private function qready(l:LoaderEvent) {
			trace ("next Question elements Ready");
			//trace (_model.questionWhich[0].
			dispatchEvent(new Event(Question.QREADY));
		}
		
		private function fready(l:LoaderEvent) {
			trace ("final Question elements Ready");
			dispatchEvent(new Event(Question.FREADY));
		}
		
	}

}