package  
{
	import adobe.utils.CustomActions;
	import com.greensock.dataTransfer.XMLManager;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.*;
	import com.greensock.loading.core.LoaderCore;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	/**
	 * ...
	 * @author Fard Muhammad
	 */
	public class JackModel extends EventDispatcher
	{
		static public const READY:String = "ready";
		static public const LOADERREADY:String = "loaderReady";
		public static const NEXTUP:String = "nextup"
		public static const OHWELL:String = "ohwell"
		public static const PREWRONG:String = "preWrong"
		public static const POSTWRONG:String = "postWrong"
		public static const QEND:String = "questionEnd"
		public static const MUSIC:String = "music"
		static public const UPDATESCORE:String = "updatescore";
		static public const RIGHTANSWER:String = "rightanswer";
		static public const WRONGANSWER:String = "wronganswer";
		
		
		//SINGLETON FUNCTIONS
		private static var _instance:JackModel;
		private var _xmlObj:Object;
		public static function getInstance():JackModel {
			if (_instance == null) _instance = new JackModel();
			return _instance;
		}
		
		private var _nextUpUsed:Array = [];
		private var _ohwellUsed:Array = [];
		private var _preWrongUsed:Array = [];
		private var _postWrongUsed:Array = [];
		private var _questionEndUsed:Array = [];
		private var _musicUsed:Array = [];
		
		private var _fordAnswered:Boolean = false;
		
		//GOOD STUFF
		private var _score:int = 0;
		private var _questionAmount:int = 2000;
		private var _currentQuestion:int = 0;
		
		private var _mondo:LoaderMax;
		private var _loader:XMLLoader;
		
		public function JackModel() 
		{
			
		}
		
		public function loadAll(main:JackMain) {
			
			/**/

			//if (_mondo) {
				//_mondo.unload();
			//}
			//_mondo = new LoaderMax( { name:"mondoLoader", onComplete:mainDone, requireWithRoot:main } );
			//_mondo.append(_loader);
			//_mondo.append(new SelfLoader(main));
			//dispatchE	vent(new Event(LOADERREADY))
			//_mondo.load();//*/
			//_loader.load();
		}
		
		public function mainDone() {
			_loader = LoaderMax.getLoader("mainXML");
			_xmlObj = XMLManager.XMLToObject(_loader.content);
			var i:uint
			for (i = 0; i < _xmlObj.preload[0].LoaderMax[0].nextUp[0].MP3Loader.length; i++)
				_nextUpUsed.push(false);
				
			for (i = 0; i < _xmlObj.preload[0].LoaderMax[0].ohwell[0].MP3Loader.length; i++)
				_ohwellUsed.push(false);
				
			for (i = 0; i < _xmlObj.preload[0].LoaderMax[0].SFX[0].prewrong[0].MP3Loader.length; i++)
				_preWrongUsed.push(false);
				
			for (i = 0; i < _xmlObj.preload[0].LoaderMax[0].SFX[0].postwrong[0].MP3Loader.length; i++)
				_postWrongUsed.push(false);
				
			for (i = 0; i < _xmlObj.preload[0].LoaderMax[0].SFX[0].questionEnd[0].MP3Loader.length; i++)
				_questionEndUsed.push(false);
				
			for (i = 0; i < _xmlObj.preload[0].LoaderMax[0].music[0].qmusic[0].dummyNode.length; i++)
				_musicUsed.push(false);
				
				
			dispatchEvent(new Event(READY))
		}
		
		public function get fullXML():Object {
			return _xmlObj;
		}
		
		public function get preload():Object {
			return _xmlObj.preload[0].LoaderMax[0];
		}
		
		public function get SFX():Object {
			return _xmlObj.preload[0].LoaderMax[0].SFX[0];
		}
		
		public function get music():Object {
			return _xmlObj.preload[0].LoaderMax[0].music[0];
		}
		
		public function get firstUp():Object {
			return _xmlObj.preload[0].LoaderMax[0].firstUp[0];
		}
		public function get nextUp():Object {
			return _xmlObj.preload[0].LoaderMax[0].nextUp[0];
		}
		
		public function get ohwell():Object {
			return _xmlObj.preload[0].LoaderMax[0].ohwell[0];
		}
		
		public function get postwrong():Object {
			return _xmlObj.preload[0].LoaderMax[0].SFX[0].postwrong[0];
		}
		
		public function get scruples():Object {
			return _xmlObj.preload[0].LoaderMax[0].scruples[0].LoaderMax[0];
		}
		
		public function get questionWhich():Object {
			//Remember- this returns all the loadermax objects in the questions (each Loadermax is a question). Select your question by using [].
			return _xmlObj.question[0].LoaderMax;
			//trace (_xmlObj.question[0].LoaderMax[0]);
		}
		
		public function get finalRound():Object {
			//There's only one final round, so there won't be multiple LoaderMax objects.
			return _xmlObj.question[0].LoaderMax[_xmlObj.question[0].LoaderMax.length - 1];
		}
		
		public function wrongAnswer() {
			_score -= _questionAmount;
			dispatchEvent(new Event(WRONGANSWER));
		}
		
		public function rightAnswer() {
			_score += _questionAmount;
			dispatchEvent(new Event(RIGHTANSWER));
		}
		
		public function wrongFinal() {
			_score -= _questionAmount * 2;
			//trace( "_score : " + _score );
		}
		
		public function rightFinal() {
			_score += _questionAmount * 2;
			//trace( "_score : " + _score );
		}
		
		public function get loader():LoaderMax 
		{
			return _mondo;
		}
		
		public function get currentQuestion():int 
		{
			return _currentQuestion;
		}
		
		public function get fordAnswered():Boolean 
		{
			return _fordAnswered;
		}
		
		public function get score():int 
		{
			return _score;
		}
		
		public function get scoreString():String {
			var str:String = Math.abs(score).toString();
			
			var index:uint = str.length;
			var sub:String, newStr:String = "";
			while (index - 3 > 0) {
				sub = str.substr(index - 3, 3);
				newStr = (index > 3) ? "," + sub + newStr : sub + newStr;
				index -= 3;
			}
			if (index > 0) {
				newStr = str.substr(0, index) + newStr;
			}
			
			newStr = (score < 0) ? "-$" + newStr : "$" + newStr;
			return newStr;
		}
		
		public function setUnused(whichSet:String):uint {
			var arr:Array;
			
			switch (whichSet) {
				case NEXTUP:
					arr = _nextUpUsed;
					break;
				case OHWELL:
					arr = _ohwellUsed;
					break;
				case PREWRONG:
					arr = _preWrongUsed;
					break;
				case POSTWRONG:
					arr = _postWrongUsed;
					break;
				case QEND:
					arr = _questionEndUsed;
					break;
				case MUSIC:
					arr = _musicUsed;
					break;
				default:
					return 0;
			}
			
			var index:uint = uint(Math.random() * arr.length);
			while (arr[index]) {
				index = uint(Math.random() * arr.length);
				//trace( "rand : " + rand );
			}
			
			if (index >= arr.length) {
				index = arr.length - 1;
			} 
			arr[index] = true;
			//Set random variable of the array so as to maintain different values and avoid repeats.
			
			//Check to see if all the entries in arr have been used up.
			var i:uint = 0;
			var stillMore:Boolean = false;
			for (i = 0; i < arr.length; i++ ) {
				if (!arr[i]) stillMore = true;
			}
			
			//if they have been all used up (there aren't stillMore spaces to be filled), then reset all...
			//but set the last spoken one to true.
			if (!stillMore) {
				for (i = 0; i < arr.length; i++) arr[i] = false;
				arr[index] = true;
			}
			return index;
		}
		
		public function ford() {
			_fordAnswered = true;
		}
		
		public function incrementQuestion():int {
			return ++_currentQuestion;
		}
		
		public function loadCurrentQuestion() {
			var qLoader:LoaderMax = LoaderMax.getLoader("Q" + _currentQuestion);
		}
		
		public function getLoader(name:String):* {
			return LoaderMax.getLoader(name);
		}
		
	}

}