package  
{
	import com.greensock.dataTransfer.XMLManager
	import com.greensock.easing.Linear;
	import com.greensock.easing.Strong;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.LoaderMax;
	import com.greensock.loading.MP3Loader;
	import com.greensock.loading.VideoLoader;
	import com.greensock.TweenLite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getDefinitionByName;
	/**
	 * ...
	 * @author Fard Muhammad
	 */
	public class QuestionMultChoice extends Question
	{
		static public const QDONE:String = "qMultDone";
		public var questionNum_txt:TextField;
		public var rightReveal:TextField;
		public var questionTitle:MovieClip;
		public var qText:TextField;
		public var answer0:MovieClip, answer1:MovieClip, answer2:MovieClip, answer3:MovieClip;
		private var rightAnswer:uint;
		private var answer:int;
		private var rightSound:MP3Loader
		private var swoosh:MP3Loader;
		private var choiceSound:MP3Loader;
		private var coda:MP3Loader;
		private var introSound:MP3Loader;
		private var titleSound:MP3Loader;
		private var qpreQuestion:MP3Loader;
		private var questionSound:MP3Loader;
		private var bgMusic2:MP3Loader;
		private var click:MP3Loader;
		private var wrongSound:MP3Loader;
		private var crash:MP3Loader;
		private var fTrans:MP3Loader;
		private var postWrong:MP3Loader;
		private var correctAnswer:MP3Loader;
		private var qEnd:MP3Loader;
		private var bgMusicBegin:Number;
		private var bgMusicEnd:Number;
		
		private var qMusicChannel:SoundChannel
		private var qMusic:Sound;
		private var rMusic:Sound;
		private var questionSpeakDone:Boolean;
		private var titleBMP:Bitmap;
		
		
		public function QuestionMultChoice() 
		{
			super();
		}
		
		public override function initData(qData:Object) {
			//trace( "qData : " + qData );
			_qData = qData;
			//trace ("init " + _qData.name);
			
			rightAnswer = uint(_qData.c) //The number value of the correct question.
			
			
			
			//Get the video and play it.
			vid = _model.getLoader(_qData.video[0].VideoLoader[0].name);
			videoLoader.addChild(vid.content);
			vid.addEventListener(VideoLoader.VIDEO_COMPLETE, intro);			
			vid.gotoVideoTime(0, true);



			//Get the text
			questionNum_txt.text = "question " + (_model.currentQuestion + 1).toString();
			questionTitle.title_txt.text = _qData.title[0].text[0].nodeValue;
			fitToArea(questionTitle.title_txt);
			qText.htmlText = _qData.question[0].text[0].nodeValue;
			qText.y = 280 - qText.textHeight / 2;
			//Get the text for each answer choice. We only do four, of course.
			for (var i:uint = 0; i < 4; i++) {
				this["answer" + i.toString()].answerNum.text = (i + 1).toString() + ".";
				this["answer" + i.toString()].answerTxt.text = _qData.response[i].text[0].nodeValue;
				this["answer" + i.toString()].y -= 15;
				this["answer" + i.toString()].alpha = 0;
			}
			
			
			//Create a bitmap for the title.
			var titleBData:BitmapData = new BitmapData(questionTitle.title_txt.textWidth, questionTitle.title_txt.height, true, 0);
			titleBData.draw(questionTitle.title_txt);
			titleBMP = new Bitmap(titleBData, "auto", true);
			titleBMP.x = titleBMP.width / -2;
			titleBMP.y = titleBMP.height / -2;
			questionTitle.title_txt.visible = false;
			questionTitle.addChild(titleBMP);

			//Get the sound effects.
			//The correct answer
			correctAnswer = _model.getLoader(_qData.response[rightAnswer].MP3Loader[0].name);
			correctAnswer.gotoSoundTime(0);
			//The speech after the answer
			coda = null;
			if (_qData.coda) {
				if (_qData.coda[0].MP3Loader) {
					coda = _model.getLoader(_qData.coda[0].MP3Loader[0].name);
					coda.gotoSoundTime(0);
				}
			}
			//trace ("coda " + coda);
			//The swoosh as the question is given
			swoosh = _model.getLoader(_model.SFX.swoosh[0].MP3Loader[0].name);
			swoosh.gotoSoundTime(0);
			//The click when the user selects an answer
			click = _model.getLoader(_model.SFX.click[0].MP3Loader[0].name);
			click.gotoSoundTime(0);

			//The right sound effect
			rightSound = _model.getLoader(_model.SFX.right[0].MP3Loader[0].name);
			rightSound.gotoSoundTime(0);
			
			//Intro to the round ("First up" or "And Coming up next")
			var rand:uint
			if (_model.currentQuestion == 0) {
				rand = uint(Math.random() * _model.firstUp.MP3Loader.length);
				introSound = _model.getLoader(_model.firstUp.MP3Loader[rand].name);
			} else {
				rand = _model.setUnused(JackModel.NEXTUP);
				introSound = _model.getLoader(_model.nextUp.MP3Loader[rand].name);
			}
			introSound.gotoSoundTime(0);
			//The sound heard after the song is over
			rand = _model.setUnused(JackModel.QEND);
			qEnd = _model.getLoader(_model.SFX.questionEnd[0].MP3Loader[rand].name);
			qEnd.gotoSoundTime(0);
			
			//Prewrong sound
			rand = _model.setUnused(JackModel.PREWRONG)
			wrongSound = _model.getLoader(_model.SFX.prewrong[0].MP3Loader[rand].name);
			wrongSound.gotoSoundTime(0);
			
			//The "Oh well" sound ("Should have picked this...")
			rand = _model.setUnused(JackModel.OHWELL)
			fTrans = _model.getLoader(_model.ohwell.MP3Loader[rand].name);
			fTrans.gotoSoundTime(0);
			
			//The postWrong sound ("Sound effect when the correct answer is shown")
			rand = _model.setUnused(JackModel.POSTWRONG);
			postWrong = _model.getLoader(_model.postwrong.MP3Loader[rand].name);
			postWrong.gotoSoundTime(0);
			
			//The questionEnd sound- heard after the music ends.

			//Crash sound effect after wrong answer.
			crash = _model.getLoader(_model.SFX.wrong[0].MP3Loader[0].name);
			crash.gotoSoundTime(0);
			
			//Question Title
			titleSound = _model.getLoader(_qData.title[0].MP3Loader[0].name);
			titleSound.gotoSoundTime(0);
			//Pre-Question intro ("You remember how to add right? Well,....")
			qpreQuestion = null;
			if (_qData.intro) {
				if (_qData.intro[0].MP3Loader) {
					qpreQuestion = _model.getLoader(_qData.intro[0].MP3Loader[0].name);
				}
			}
			//Bg music played while question is being read.
			/*bgTheme = _model.setUnused(JackModel.MUSIC) //bgTheme is a uint to choose one theme for both qmusic and rmusic
			bgMusic = _model.getLoader(_model.music.qmusic[0].MP3Loader[bgTheme].name);
			bgMusicBegin = Number(_model.music.qmusic[0].MP3Loader[bgTheme].begin);
			bgMusicEnd = (_model.music.qmusic[0].MP3Loader[bgTheme].end) ? Number (_model.music.qmusic[0].MP3Loader[bgTheme].begin) : bgMusic.duration;
			bgMusic.gotoSoundTime(0);
			bgMusic2 = _model.getLoader(_model.music.rmusic[0].MP3Loader[bgTheme].name);
			bgMusic2.gotoSoundTime(0);*/
			
			bgTheme = _model.setUnused(JackModel.MUSIC);
			var QMusicClass:Class, RMusicClass:Class;
			QMusicClass = getDefinitionByName("Q" + bgTheme.toString() + "1") as Class;
			RMusicClass = getDefinitionByName("Q" + bgTheme.toString() + "2") as Class;
			
			qMusic = new QMusicClass();
			rMusic = new RMusicClass();
			
			questionSpeakDone = false;
			
			
			//The question
			questionSound = _model.getLoader(_qData.question[0].MP3Loader[0].name);
			questionSound.gotoSoundTime(0);
			//The choices
			choiceSound = _model.getLoader(_qData.choices[0].MP3Loader[0].name);
			choiceSound.gotoSoundTime(0);
			//if there is another mult choice question ahead, then load it.
				//trace( "_model.questionWhich.length - 1 : " + (_model.questionWhich.length - 1) );
				//trace( "_model.currentQuestion : " + _model.currentQuestion );

		}
		
		private function intro(e:Event):void 
		{
			//Intro to the question- "First up" or "Coming up next..."
			if (_model.currentQuestion < (_model.questionWhich.length - 1)) {
				trace ("loading next question");
				_command.preLoadQuestion(_model.currentQuestion + 1);
			} else {
				trace ("LOADING FINAL ROUND");
				_command.preLoadQuestion(-1);
				//trace ("no more mult choice after this");
			}//if not, check if there's a FardForceQuestion.
			vid.dispose(true);
			introSound.addEventListener(MP3Loader.SOUND_COMPLETE, showTitle);
			introSound.playSound();
			//introSound.gotoSoundTime(0, true);
		}
		
		private function showTitle(e:Event):void 
		{
			introSound.removeEventListener(MP3Loader.SOUND_COMPLETE, showTitle);
			//Show the title.  After .275 seconds, play the sound accompanying the title.
			TweenLite.to(questionTitle, .5, { x: 400 } );
			TweenLite.delayedCall(.275, playTitle);
		}
		
		private function playTitle(e:Event = null):void {
			//play the title narration
			titleSound.addEventListener(MP3Loader.SOUND_COMPLETE, moveTitleAway);
			titleSound.playSound();
		}
		
		private function moveTitleAway(m:LoaderEvent) {
			//Move the title to the upper right hand side, and put in the question number.
			TweenLite.to(questionTitle, .2, { x:780 - (questionTitle.title_txt.textWidth / 2 * .6) , y:25, scaleX:.6, scaleY:.6, tint:0x888888, ease:Strong.easeInOut } );
			TweenLite.to(questionNum_txt, .2, { x:20, delay: .1, onComplete:playNext } );
			_command.showScore();
		}
		
		private function playNext() {
			//If there is an intro, play it. If not, just show the question.
				trace( "qpreQuestion : " + qpreQuestion );
			if (qpreQuestion) {
				qpreQuestion.addEventListener(MP3Loader.SOUND_COMPLETE, showQuestion);
				qpreQuestion.playSound();
			} else {
				trace ("NO INTRO");
				_command.addEventListener(JackCommand.STARTQUESTION, showQuestion);
			}
		}
		
		private function showQuestion(e:Event = null):void 
		{
			if (_command.hasEventListener(JackCommand.STARTQUESTION)) _command.removeEventListener(JackCommand.STARTQUESTION, showQuestion);
			//Show the question.
			swoosh.playSound();
			//bgMusic.volume = .8;
			//bgMusic.playSound(); //this is set to repeat indefinitely until the question is fully read.
			qMusicChannel = qMusic.play();
			var st:SoundTransform = new SoundTransform(.6);
			qMusicChannel.soundTransform = st;
			qMusicChannel.addEventListener(Event.SOUND_COMPLETE, repeat);
			TweenLite.to(qText, .3, { x: 50 } );
			TweenLite.delayedCall(.2, sayQuestion);
		}
		
		private function sayQuestion():void 
		{
			//Say the question after showing it (.2 seconds later)
			//trace ("say question " +_qData.name);
			questionSound.addEventListener(MP3Loader.SOUND_COMPLETE, moveQuestionUp);
			questionSound.playSound();
		}
		
		private function moveQuestionUp(l:LoaderEvent):void {
			//Move the question up and show the choices. 2 seconds later, set the buttons open to keyboard input.
			questionSound.removeEventListener(MP3Loader.SOUND_COMPLETE, moveQuestionUp);
			TweenLite.to(qText, .2, { y:150-(qText.textHeight / 2), delay:.8 } );
			//trace ("move question " +_qData.name);
			choiceSound.addEventListener(MP3Loader.SOUND_COMPLETE, setQuestionOver);
			//choiceSound.playSound();
			TweenLite.delayedCall(.8, choiceSound.playSound);
			for (var i:uint = 0; i < 4; i++) {
				TweenLite.to(this["answer" + i], .4, { delay:(1 + i * .1), y:"15", alpha:1 } );
				this["answer" + i].answerBox.visible = false;
				this["answer" + i].answerBoxShadow.visible = false;
				
			}
			TweenLite.delayedCall(2, setButtons);
		}
		
		private function setQuestionOver(e:Event) {
			questionSpeakDone = true;
		}
			
		private function repeat(e:Event) {
			var st:SoundTransform = new SoundTransform(.6);
			if (!questionSpeakDone) {
				qMusicChannel = qMusic.play();
				qMusicChannel.soundTransform = st;;
				qMusicChannel.addEventListener(Event.SOUND_COMPLETE, repeat);
			} else {
				qMusicChannel.removeEventListener(Event.SOUND_COMPLETE, repeat);
				qMusicChannel = rMusic.play();
				qMusicChannel.soundTransform = st;
				qMusicChannel.addEventListener(Event.SOUND_COMPLETE, noAnswer);
			}
		}
		/*private function startRMusic(e:Event):void 
		{
			//qMusicChannel.
			//1 second later, start the secondary music
			TweenLite.delayedCall(1, startRMusicDelay);
		}
		
		private function startRMusicDelay() {
			bgMusic.pauseSound();
			bgMusic2.addEventListener(MP3Loader.SOUND_COMPLETE, noAnswer);
			bgMusic2.playSound();
		}*/
		
		
		protected override function keyPressed(k:KeyboardEvent)
		{
			//Here is where interpret the key being depressed (the event listener is set in the superclass)
			//trace(k.keyCode);
			//1-4 are 49-52 in text, so to make things easier, we set a value to 0-3 to match the XML.
			answer = (k.charCode - 49);
			if (answer >= 0 && answer < 4) { //if it's 0-3 
				//TweenLite.killDelayedCallsTo(startRMusicDelay); //If the answer is made before the music is to begin, don't begin it.
				qMusicChannel.stop(); //Pause the music
				//bgMusic.gotoSoundTime(0);
				//bgMusic2.pauseSound(); //Pause the other music
				qMusicChannel.removeEventListener(MP3Loader.SOUND_COMPLETE, noAnswer);
				choiceSound.pauseSound(); //If the answer is made while the choices are being read, stop it.
				unsetButtons(); //Answer's been made, we don't need more keyboard input.
				//Start answer animation
				this["answer" + answer].answerBox.visible = true; 
				this["answer" + answer].answerBoxShadow.visible = true;
				this["answer" + answer].addEventListener(Event.ENTER_FRAME, flop);
				//Click sound effect and say answer afterward
				click.addEventListener(MP3Loader.SOUND_COMPLETE, sayAnswer);
				click.playSound();
				//Ford answer.
				//if (_qData.response[answer].ford) {
					//_model.ford();
				//}
					
			}
		}
		
		private function sayAnswer(e:Event):void {
			//Say the answer. This is not defined at the beginning because we don't know which answer will be chosen.
			click.removeEventListener(MP3Loader.SOUND_COMPLETE, sayAnswer);
			var answerSound:MP3Loader = _model.getLoader(_qData.response[answer].MP3Loader[0].name);
			answerSound.addEventListener(MP3Loader.SOUND_COMPLETE, nowWhat);
			answerSound.playSound();
		}
		
		private function nowWhat(e:Event) {
			//After the answer's been given, we check if the answer's right.
			if (answer == rightAnswer) {
				rightAnswerAnim();
			} else {
				wrongAnswerAnim();
			}
		}
		
		private function wrongAnswerAnim():void 
		{
			//The wrong answer has been given. 
			var wrongSelect:MovieClip = this["answer" + answer];
			wrongSound.addEventListener(MP3Loader.SOUND_COMPLETE, wrongComplete);
			wrongSound.playSound();
			wrongSelect.removeEventListener(Event.ENTER_FRAME, flop);
			wrongSelect.answerBoxShadow.visible = false;
			wrongSelect.answerBox.x = 2.5
			wrongSelect.answerBox.y = 2.5
			TweenLite.to(wrongSelect, .3, { x:801, ease:Strong.easeIn } );
		}
		
		private function scoreDown():void 
		{
			_model.wrongAnswer()
		}
		
		private function wrongComplete(e:Event):void 
		{
			wrongSound.removeEventListener(MP3Loader.SOUND_COMPLETE, wrongComplete);
			crash.addEventListener(MP3Loader.SOUND_COMPLETE, ohwell);
			crash.playSound();
			scoreDown();
		}
		
		private function noAnswer(e:Event):void {
			unsetButtons();
			qEnd.addEventListener(MP3Loader.SOUND_COMPLETE, ohwell);
			qEnd.playSound();
		}
		
		private function ohwell(e:Event):void 
		{
			if (crash.hasEventListener(MP3Loader.SOUND_PLAY)) crash.removeEventListener(MP3Loader.SOUND_PLAY, scoreDown);
			if (crash.hasEventListener(MP3Loader.SOUND_COMPLETE)) crash.removeEventListener(MP3Loader.SOUND_COMPLETE, ohwell)
			if (qEnd.hasEventListener(MP3Loader.SOUND_COMPLETE)) qEnd.removeEventListener(MP3Loader.SOUND_COMPLETE, ohwell)
			fTrans.addEventListener(MP3Loader.SOUND_COMPLETE, showCorrectAnswer);
			fTrans.playSound();
		}
		
		private function showCorrectAnswer(e:Event):void 
		{
			fTrans.removeEventListener(MP3Loader.SOUND_COMPLETE, showCorrectAnswer);
			for (var i = 0; i < 4; i++) {
				this["answer" + i.toString()].visible = 0;
			}
			rightReveal.text = _qData.response[rightAnswer].text[0].nodeValue;
			postWrong.addEventListener(MP3Loader.SOUND_COMPLETE, playCorrectAnswer);
			postWrong.playSound();
		}
		private function playCorrectAnswer(e:Event) {
			postWrong.removeEventListener(MP3Loader.SOUND_COMPLETE, playCorrectAnswer);
			correctAnswer.addEventListener(MP3Loader.SOUND_COMPLETE, endQuestion);
			correctAnswer.playSound();
		}
		private function endQuestion(e:Event):void {
			if (correctAnswer.hasEventListener(MP3Loader.SOUND_COMPLETE)) correctAnswer.removeEventListener(MP3Loader.SOUND_COMPLETE, endQuestion);
			if (rightSound.hasEventListener(MP3Loader.SOUND_COMPLETE)) rightSound.removeEventListener(MP3Loader.SOUND_COMPLETE, endQuestion);
			if (coda) {
				coda.addEventListener(MP3Loader.SOUND_COMPLETE, questionOver);
				coda.playSound();
			}
			else questionOver();
		}
		
		private function rightAnswerAnim():void 
		{
			
			var correct:MovieClip = this["answer" + answer];
			correct.removeEventListener(Event.ENTER_FRAME, flop);
			correct.answerBoxShadow.visible = false;
			correct.answerBox.x = 2.5;
			correct.answerBox.y = 2.5;
			rightSound.addEventListener(MP3Loader.SOUND_COMPLETE, endQuestion);
			rightSound.playSound();
			var tf:TextFormat = new TextFormat();
			tf.color = 0xDD0000;
			correct.answerTxt.setTextFormat(tf);
			TweenLite.to(correct.answerBox, .1, { width:700, ease:Linear.easeNone, onComplete:scoreUp } );
		}
		
		private function scoreUp():void 
		{
			_model.rightAnswer();
		}
		
		private function questionOver(e:Event=null):void 
		{
			if (coda) coda.removeEventListener(MP3Loader.SOUND_COMPLETE, questionOver);
			_command.hideScore();
			dispatchEvent(new Event(QDONE, true));
		}
		
		
		private function flop(e:Event):void 
		{
			var chosenAnswer:MovieClip = this["answer" + answer];
			chosenAnswer.answerBoxShadow.x = chosenAnswer.answerBox.x;
			chosenAnswer.answerBoxShadow.y = chosenAnswer.answerBox.y;
			chosenAnswer.answerBox.x = Math.random() * 5;
			chosenAnswer.answerBox.y = Math.random() * 5;
		}
		
		
		//protected override function keyPressed
		
	}

}