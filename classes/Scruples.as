package  
{
	import adobe.utils.CustomActions;
	import com.greensock.easing.Back;
	import com.greensock.easing.Bounce;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.MP3Loader;
	import com.greensock.loading.VideoLoader;
	import com.greensock.TweenLite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.NetStatusEvent;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author Fard Muhammad
	 */
	public class Scruples extends Question
	{
		static public const KILLINTRO:String = "killintro";
		private var _scruplesObj:Object
		//private var _model:JackModel;
		public var question:MovieClip;
		public var choice0:MovieClip, choice1:MovieClip;
		public var line0:TextField, line1:TextField;
		public var videoLoadMC:MovieClip;
		public var titleScreen:MovieClip;
		//private var vid:VideoLoader;
		private var choices:Object;
		//private var _command:JackCommand;
		//private var bgMusic:MP3Loader;
		private var shimmer:MP3Loader;
		private var voice:MP3Loader, voiceBored:MP3Loader, goodBye:MP3Loader;
		//private var bgTheme:uint;
		
		public function Scruples() 
		{
			//_model = JackModel.getInstance();
			//_command = JackCommand.getInstance();
			question.alpha = 0;
			choice0.alpha = 0;
			choice1.alpha = 0;
			line0.alpha = 0;
			line1.alpha = 0;
		}
		
		public override function initData(scruplesObj:Object) { //scruples[0]
			/*Tree-
			 * choice[0-1].answer[0].nodeValue
			 *            .response[0].line[0-1].time
			 *                                  .nodeValue
			 * question[0].nodeValue
			 * VideoLoader[0].name
			 */
			
			 
			//IT IS HERE THAT YOU PRELOAD THE FIRST QUESTION.
			_command.preLoadQuestion(_model.currentQuestion);
			_scruplesObj = scruplesObj;
			bgTheme = Math.floor(Math.random() * scruplesObj.themeMusic[0].MP3Loader.length);
			choices = scruplesObj.choice;
			question.scruplesQ_txt.text = scruplesObj.question[0].nodeValue;
			question.scruplesQ_txt.y = -(question.scruplesQ_txt.textHeight / 2);
			var txt_bData:BitmapData = new BitmapData(question.scruplesQ_txt.width, question.scruplesQ_txt.height, true, 0);
			var text_bmp:Bitmap = new Bitmap(txt_bData);
			text_bmp.smoothing = true;			
			text_bmp.bitmapData.draw(question.scruplesQ_txt);
			question.scruplesQ_txt.visible = false;
			question.addChild(text_bmp);
			text_bmp.x = question.scruplesQ_txt.x;
			text_bmp.y = question.scruplesQ_txt.y;
			choice0.choice_txt.text = scruplesObj.choice[0].answer[0].nodeValue;
			choice1.choice_txt.text = scruplesObj.choice[1].answer[0].nodeValue;
			vid = _model.getLoader(scruplesObj.VideoLoader[0].name);
			videoLoadMC.addChild(vid.content);
			vid.addEventListener(VideoLoader.VIDEO_COMPLETE, stopVideo);
			vid.gotoVideoTime(0, true);
			TweenLite.delayedCall(3, textAnim);
			bgMusic = _model.getLoader(_scruplesObj.themeMusic[0].MP3Loader[bgTheme].name);
			shimmer = _model.getLoader(_scruplesObj.shimmer[0].MP3Loader[0].name);
			voice = _model.getLoader(_scruplesObj.voice[0].MP3Loader[Math.floor(Math.random() * _scruplesObj.voice[0].MP3Loader.length)].name);
			voiceBored = _model.getLoader(_scruplesObj.voiceBored[0].MP3Loader[Math.floor(Math.random() * _scruplesObj.voiceBored[0].MP3Loader.length)].name);
			goodBye = _model.getLoader(_scruplesObj.goodBye[0].MP3Loader[Math.floor(Math.random() * _scruplesObj.goodBye[0].MP3Loader.length)].name);
			bgMusic.addEventListener(MP3Loader.SOUND_COMPLETE, getBored);
			bgMusic.playSound();
		}
		
		private function stopVideo(e:Event) {
			//vid.dispose(true);
		}
		
		private function getBored(e:Event) {
			TweenLite.delayedCall(2, sayBored);
		}
		
		private function sayBored() {
			voiceBored.addEventListener(MP3Loader.SOUND_COMPLETE, startTheClock);
			voiceBored.playSound();
		}
		
		private function startTheClock(e:Event) {
			TweenLite.delayedCall(5, sayGoodBye);
		}
		
		private function sayGoodBye() {
			unsetButtons();
			TweenLite.to(question, 1, { alpha: 0 } );
			TweenLite.to(choice0, 1, { alpha:0 } );
			TweenLite.to(choice1, 1, { alpha:0 } );
			goodBye.addEventListener(MP3Loader.SOUND_COMPLETE, getOut);
			goodBye.playSound();
		}
		
		private function getOut(e:Event) {
			navigateToURL(new URLRequest("http://www.fardmuhammad.com/?page_id=2"), "_self");
		}
		
		private function textAnim(e:Event = null):void 
		{
			//trace("animated text");
			moveChoice(0, 0);
			moveChoice(0, 1);
			moveChoice(1, 0);
			moveChoice(1, 1);
			TweenLite.to(question, .5, { alpha:1 } );
			TweenLite.from(question, 5, { scaleX:.8, scaleY:.8, overwrite:false } ); 
			
			
			TweenLite.to(choice0, .5, { alpha:1, delay:5, onStart:playShimmer, overwrite:false} );
			TweenLite.to(choice1, .5, { alpha:1, delay:6.5, onStart:playShimmer, onStartParams:[true], onComplete:setButtons, overwrite:false} );
			TweenLite.delayedCall(7.5, voice.playSound);
			
		}
		
		private function moveChoice(which:uint, axis:uint) {
			var defaultPos:Number = (axis) ? (which) ? 590 : 190 : 500;
			if (axis) {
				TweenLite.to(this["choice" + which.toString()], Math.random() * 2 + 3, { x: defaultPos + (Math.random() * 50 - 25), onComplete:moveChoice, onCompleteParams:[which, axis], overwrite:false } );
			} else {
				TweenLite.to(this["choice" + which.toString()], Math.random() * 2 + 3, { y: defaultPos + (Math.random() * 20 - 10), onComplete:moveChoice, onCompleteParams:[which, axis], overwrite:false } );
			}
		}
		
		private function playShimmer(playVoice:Boolean = false ) {
			shimmer.gotoSoundTime(0);
			if (playVoice) 
			{
				//stage.addEventListener(KeyboardEvent.KEY_DOWN, oneTwo);
				shimmer.addEventListener(MP3Loader.SOUND_COMPLETE, voice.playSound);
			}
			shimmer.playSound();
		}
		
		protected override function keyPressed(k:KeyboardEvent)
		{
			//trace ("key pressed");
			switch (k.keyCode) {
				case 49:
					goAnswer(0);
					break;
				case 50:
					goAnswer(1)
					break;
				default:
					break;
			}
		}
		
		private function goAnswer(arg1:Number):void
		{
			unsetButtons();
			TweenLite.killTweensOf(choice0);
			TweenLite.killTweensOf(choice1);
			TweenLite.killDelayedCallsTo(sayGoodBye);
			TweenLite.killDelayedCallsTo(sayBored);
			voice.pauseSound();
			voiceBored.pauseSound();
			shimmer.pauseSound();
			TweenLite.killDelayedCallsTo(voice.playSound);
			bgMusic.pauseSound();
			bgMusic.unload();
			bgMusic = _model.getLoader(_scruplesObj.responseMusic[0].MP3Loader[bgTheme].name);
			bgMusic.playSound();
			var time0:Number, time1:Number;
			var theAnswer:MovieClip = this["choice" + arg1.toString()]
			question.visible = false;
			if (arg1) choice0.visible = false;
			else choice1.visible = false;
			
			theAnswer.width += 20
			theAnswer.scaleY = theAnswer.scaleX;
			theAnswer.y = 480;
			theAnswer.x = (arg1) ? 570 : 210; 
			
			line0.text = choices[arg1].response[0].line[0].nodeValue;
			time0 = choices[arg1].response[0].line[0].time;
			line1.text = choices[arg1].response[0].line[1].nodeValue;
			time1 = choices[arg1].response[0].line[1].time;
			
			TweenLite.to(theAnswer, .6, { alpha:0, visible:false, delay:3 } );
			TweenLite.to(line0, .6, { alpha:1, delay:3 } );
			TweenLite.to(line1, .6, { alpha:1, delay:3 + time0 } );
			TweenLite.delayedCall(3 + time1 + time0, slam);
			TweenLite.to(titleScreen, .4, { y:0, ease:Back.easeOut, delay:3 + time1+time0 } );
			TweenLite.to(titleScreen, .15, { blurFilter: { blurY:0 }, delay:3 + time1 + time0 + .2, overwrite:false } );
		}
		
		private function slam():void 
		{
			bgMusic.pauseSound();
			bgMusic.unload();
			bgMusic = _model.getLoader(_scruplesObj.clang[0].MP3Loader[0].name);
			bgMusic.addEventListener(MP3Loader.SOUND_COMPLETE, introSoundGo);
			bgMusic.playSound();
		}
		
		
		
		private function introSoundGo(e:Event=null):void 
		{
			bgMusic.unload();
			bgMusic.dispose();
			var rand:String = (Math.floor(Math.random() * _scruplesObj.gameIntro[0].MP3Loader.length)).toString();
			var intro:MP3Loader = _model.getLoader("I" + rand);
			intro.addEventListener(MP3Loader.SOUND_COMPLETE, introOver);
			TweenLite.delayedCall(.2, function() { intro.playSound() } );
		}
		
		private function introOver(e:Event) {
			dispatchEvent(new Event(KILLINTRO));
		}
		
		
	}

}