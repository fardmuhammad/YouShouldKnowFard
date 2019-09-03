package  
{
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.*;
	import com.greensock.loading.data.LoaderMaxVars;
	import com.greensock.plugins.SoundTransformPlugin;
	import com.greensock.plugins.TintPlugin;
	import com.greensock.TweenLite;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.media.Sound;
	import com.greensock.plugins.BlurFilterPlugin;
	import com.greensock.plugins.TweenPlugin;
	
	/**
	 * ...
	 * @author Fard Muhammad
	 */
	public class JackMain extends MovieClip
	{
		public var scruples:Scruples;
		private var _model:JackModel;
		private var _command:JackCommand;
		public var oneMoment:MovieClip;
		
		public var introScreen:LoadingScreen;
		public var keyboardOnly:MovieClip;
		private var bgScreen:MovieClip;
		private var question:MovieClip;
		
		private var inGame:Boolean = false;
		private var isPaused:Boolean = false;
		
		private var currentDone:Boolean = false;
		private var nextDone:Boolean = false;
		
		private var currentScreen:Question;
		private var nextScreen:Question;
		private var _loader:XMLLoader;
		
		public var score_mc:Score;
		
		private var _mondo:LoaderMax;
		
		public function JackMain() 
		{
			//Added to stage
			LoaderMax.activate([MP3Loader, VideoLoader, DataLoader]);
			TweenPlugin.activate([BlurFilterPlugin, TintPlugin]);
			if (_loader) {
				_loader.unload()
			}
			
			_loader = new XMLLoader("mondo.xml", { name:"mainXML", onComplete: modelLoad} );
			var _mondoVars:LoaderMaxVars = new LoaderMaxVars();
			_mondoVars.requireWithRoot(this);
			_mondoVars.onComplete(testName);
			_mondoVars.auditSize(false);
			_mondo = new LoaderMax(_mondoVars);
			//trace (root.parent);
			oneMoment.visible = false;
			_model = JackModel.getInstance();
			//_model.loadAll(this);
			_command = JackCommand.getInstance();
			_mondo.append(_loader);
			_mondo.load();
			trace ("THIS SHOULD LOAD");
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function testName(l:LoaderEvent) {
			trace ("OPENING: " + l.target.name);
		}
		
		private function init(e:Event) {
//			removeEventListener(Event.ADDED_TO_STAGE, init);
			//set model and command, set Ready flag for when the preloader is ready.
//			_model = JackModel.getInstance();
//			_model.loadAll(this);
//			_model.addEventListener(JackModel.READY, getGameReady); //Note- READY is right after the loader is complete. the Model saves the XML to an Object for easier access (for me).
//			_command = JackCommand.getInstance();
//		}
		
//		private function getGameReady(e:Event) {*/
			//trace ("preloaded Elements loaded");
			//Listens for when the user clicks on the "Let's Do This" button.
//			introScreen.addEventListener(LoadingScreen.KILLLOADING, startScruples);
			stage.addEventListener("KILLLOADING", startScruples);
		}
		
		private function modelLoad(l:LoaderEvent) {
			_model.mainDone();
		}

		private function showKeyboardWarning(m:MouseEvent) {
			TweenLite.killTweensOf(keyboardOnly);
			setChildIndex(keyboardOnly, this.numChildren - 1);
			keyboardOnly.alpha = 0;
			TweenLite.to(keyboardOnly, .2, { alpha:1 } );
			TweenLite.to(keyboardOnly, .2, { alpha:0, delay:1.8, overwrite:false } );
		}
		
		
		private function startScruples(e:Event) {
			//Kill the Intro Screen.
			stage.addEventListener(MouseEvent.CLICK, showKeyboardWarning);
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, _command.keyStroke);
			
			//introScreen.removeEventListener(LoadingScreen.KILLLOADING, startScruples);
			stage.removeEventListener("KILLLOADING", startScruples);
			//removeChild(introScreen);
			//introScreen = null;
			//Set Current Screen.
			currentScreen = scruples;
			//Preload Next Screen (which is Question "1")
			nextScreen = new QuestionMultChoice();
//			nextScreen = new QuestionFinal();
			addChildAt(nextScreen, 0);
			//Init the Scruples screen with preloaded info.
			scruples.initData(_model.scruples);
			//Once the user gets to the end of scruples screen, the Intro is done.
			scruples.addEventListener(Scruples.KILLINTRO, introDone);
			//Once the preloaded question is done, then the Question is ready.
			_command.addEventListener(Question.QREADY, qready);
			_command.addEventListener(Question.FREADY, fready);
			//Since we don't know which one will happen first, we'll set up a semaphore.
		}
		
		
		private function introDone(e:Event):void 
		{
			scruples.removeEventListener(Scruples.KILLINTRO, introDone);
			currentDone = true;
			//trace("Scruples Done");
			if (nextDone) killCurrent();
			else oneMoment.visible = true;
		}
		
		private function questionDone(e:Event):void {
			currentScreen.removeEventListener(QuestionMultChoice.QDONE, questionDone);
			currentDone = true;
			if (nextDone) killCurrent();
			else oneMoment.visible = true;
		}
		
		private function qready(e:Event):void {
			nextDone = true;
			trace ("question " + (_model.currentQuestion + 1).toString() + " done");
			if (currentDone) killCurrent();
		}
		
		private function fready(e:Event):void {
			nextDone = true;
			if (currentDone) killCurrent(true);
		}
			
		private function killCurrent(isFinal:Boolean = false):void {
			nextDone = false;
			currentDone = false;
			var remove:LoaderMax;
			if (currentScreen == scruples) {
				//trace ("killing scruples");
				remove = _model.getLoader("S");
			} else {
				trace ("killing question " + _model.currentQuestion);
				remove = _model.getLoader("Q" + _model.currentQuestion);
				_model.incrementQuestion();
				trace ("the current question is: " + _model.currentQuestion);
			}
			remove.dispose();
			removeChild(currentScreen);
			currentScreen.removeEventListener(QuestionMultChoice.QDONE, questionDone);
			currentScreen = null;
			
			var temp:Question = nextScreen;
			currentScreen = temp;
			trace( "currentScreen : " + currentScreen );
			addChildAt(currentScreen, 0);
			nextScreen = null;
			if (_model.questionWhich[_model.currentQuestion].final) currentScreen.addEventListener(QuestionFinal.ALLOWCLICK, mousesOn); 
			
			//_model.incrementQuestion();
			
			trace( "_model.currentQuestion : " + _model.currentQuestion );
			if ((_model.currentQuestion + 1) < _model.questionWhich.length) {
				//if (_model.currentQuestion < _model.questionWhich.length - 1) {
				if (!_model.questionWhich[_model.currentQuestion + 1].final) {
					nextScreen = new QuestionMultChoice();
				}
				else
				{
					nextScreen = new QuestionFinal();
				}

			} 
			currentScreen.initData(_model.questionWhich[_model.currentQuestion] );
			trace( "Starting Question " + _model.currentQuestion);
			currentScreen.addEventListener(QuestionMultChoice.QDONE, questionDone);
			addChildAt(currentScreen, 0);
			
		}
		
		private function mousesOn(e:Event):void 
		{
			stage.removeEventListener(MouseEvent.CLICK, showKeyboardWarning);
		}
		
	}

}