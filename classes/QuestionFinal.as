package
{
	import com.greensock.easing.Linear;
	import com.greensock.easing.Strong;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.core.LoaderCore;
	import com.greensock.loading.MP3Loader;
	import com.greensock.loading.VideoLoader;
	import com.greensock.TimelineLite;
	import com.greensock.TweenLite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.utils.getDefinitionByName;
	/**
	 * ...
	 * @author Fard Muhammad
	 */
	public class QuestionFinal extends Question
	{
		static public const ALLOWCLICK:String = "allowclick";
		private var intro:MP3Loader;
		private var clue:String;
		public var titleBMPD:BitmapData;
		public var titleBMP:Bitmap;
		public var clueMC:MovieClip;
		public var finalScore:MovieClip;
		public var finalVideoLoader:MovieClip;
		public var finalLogo:MovieClip;
		public var email:SimpleButton;
		public var credits:MovieClip;
		private var musicArr:Vector.<Sound>
		private var musicArr2:Vector.<Sound>
		private var currentMatch:QuestionFinalMatch;
		private var matchIndex:uint = 0;
		private var currentMusic:uint = 0;
		private var matches:Vector.<QuestionFinalMatch>;
		private var title:MP3Loader;
		private var finalScoreMusic:Sound;
		private var bgMusicLoop:Sound;
		private var bgMusicChannel:SoundChannel
		private var musicSecond:Boolean = false;
		private var endVid:VideoLoader;
		private var gameOver:MP3Loader;
		private var bgMusicFirst:Sound;
		private var themeSong:Sound;
		private var thought:MP3Loader;
		private var endTheme:Boolean = false;
		private var theWrongSound:MP3Loader;
		private var someTransform:SoundTransform;
		
		public function QuestionFinal() 
		{
			super();
			finalScore.visible = false;
			finalLogo.visible = false;
			credits.visible = false
			email.visible = false;
		}
		
		public override function initData(qData:Object) {
			_qData = qData;
			
			vid = _model.getLoader(_qData.video[0].VideoLoader[0].name);
			endVid = _model.getLoader(_qData.video[0].VideoLoader[1].name);
			intro = _model.getLoader(_qData.intro[0].MP3Loader[0].name);
			title = _model.getLoader(_qData.title[0].MP3Loader[0].name);
			theWrongSound = _model.getLoader(_model.SFX.attackwrong[0].MP3Loader[0].name);
			
			musicArr = new Vector.<Sound>();
			musicArr2 = new Vector.<Sound>();
			/*for (var i:uint = 0; i < _model.music.fmusic[0].MP3Loader.length; i++) {
				musicArr.push( { music: _model.getLoader(_model.music.fmusic[0].MP3Loader[i].name), 
					begin: Number(_model.music.fmusic[0].MP3Loader[i].begin), 
					end: Number(_model.music.fmusic[0].MP3Loader[i].end)});
			}*/
			//finalScoreMusic = _model.getLoader(_model.music.fmusicEnd[0].MP3Loader[0].name);
			
			var SoundClass:Class;
			for (var i:uint = 1; i < 8; i++) {
				SoundClass = getDefinitionByName("Jattack" + i.toString()) as Class;
				musicArr.push(new SoundClass());
				SoundClass = getDefinitionByName("Jattack" + i.toString() + "b") as Class;
				musicArr2.push(new SoundClass());
			}
			
			
			matches = new Vector.<QuestionFinalMatch>();
			var matchData:Object;
			for (i = 0; i < 7; i++) {
				matchData = _model.finalRound.choice[i];
				matches.push(new QuestionFinalMatch(matchData));
			}
			clue = _qData.title[0].text[0].nodeValue;
			clueMC.title.text = clue;
			
			
			//clueMC.title.y = clueMC.title.textHeight / -2;
			
			titleBMPD = new BitmapData(clueMC.title.width, clueMC.title.textHeight, true, 0xFFFFFF);
			titleBMPD.draw(clueMC);
			
			titleBMP = new Bitmap(titleBMPD, "auto", true);
			titleBMP.x = clueMC.title.width / -2;
			titleBMP.y = (clueMC.title.textHeight) / -2;
			
			clueMC.addChild(titleBMP);
			//clueMC.title.y = -clueMC.title.textHeight
			
			clueMC.rotation = -10;
			clueMC.alpha = 0;
			clueMC.title.visible = false;
			
			videoLoader.addChild(vid.content);
			vid.autoDispose = true;
			vid.addEventListener(VideoLoader.VIDEO_COMPLETE, disposeVid);
			vid.gotoVideoTime(0, true);
			trace ("VIDEO HERE");
			playMusic();
			TweenLite.delayedCall(2.5, playIntroSound);
		}		
		
		private function disposeVid(e:Event):void 
		{
			videoLoader.visible = false;
		}
		
		
		private function playMusic() {
			bgMusicFirst = new FinalMusicIntro();
			bgMusicChannel = bgMusicFirst.play();
			bgMusicChannel.addEventListener(Event.SOUND_COMPLETE, playIntroLoop);
		}
		
		private function playIntroLoop(e:Event) {
			trace("playIntroLoop")
			//bgMusicChannel.stop();
			bgMusicChannel.removeEventListener(Event.SOUND_COMPLETE, playIntroLoop);
			bgMusicFirst = new FinalMusicIntroLoop();
			bgMusicChannel = bgMusicFirst.play(0, 99);
		}
		
		/*private function doRepeat(e:LoaderEvent):void 
		{
			//if (bgMusic.soundTime >= musicArr[currentMusic].end) {
				//trace( "e.type : " + e.type );
				bgMusic.gotoSoundTime(musicArr[currentMusic].begin, true);
				//trace( "musicArr[currentMusic].begin : " + musicArr[currentMusic].begin );
			//}
		}*/
		
		private function playIntroSound() {
			
			intro.addEventListener(MP3Loader.SOUND_COMPLETE, showClue);
			intro.playSound();
		}
		
		private function showClue(e:LoaderEvent) {
			var len:Number = title.duration;
			title.addEventListener(MP3Loader.SOUND_COMPLETE, beginRound);
			title.playSound();
			
			TweenLite.to(clueMC, .1, { alpha:1 } );
			TweenLite.to(clueMC, .3, { alpha:0, rotation: 25, scaleX: .3, scaleY: .3, delay:len - .1, ease:Linear.easeNone, overwrite:false } );
			TweenLite.to(clueMC, len-.3 , { rotation : 10, scaleX: .6, scaleY:.6, ease:Linear.easeNone, overwrite:false } ); 
		}
		
		private function beginRound(e:LoaderEvent) {
			currentMatch = matches[matchIndex];
			playRound();
		}
		
		private function playRound() {
			bgMusicChannel.stop();
			
			bgMusicChannel = musicArr[currentMusic].play(0, 99);
			
			addChild(currentMatch);
			currentMatch.addEventListener(QuestionFinalMatch.MUSICSTOP, stopTheMusic);
			currentMatch.addEventListener(QuestionFinalMatch.MATCHDONE, goNext);
			currentMatch.addEventListener(QuestionFinalMatch.WRONG, soundWrong);
			currentMatch.startText(musicArr[currentMusic].length / 1000);

		}
		
		private function soundWrong(e:Event):void 
		{
			theWrongSound.gotoSoundTime(0, true);
		}
		
		private function stopTheMusic(e:Event):void 
		{
			bgMusicChannel.stop();
			bgMusicChannel = musicArr2[currentMusic].play();
			bgMusicChannel.addEventListener(Event.SOUND_COMPLETE, goNext);
			theWrongSound.pauseSound();
			//bgMusicChannel.stop();
		}
		
		private function goNext(e:Event) {
			bgMusicChannel.removeEventListener(Event.SOUND_COMPLETE, goNext);
			removeChild(currentMatch);
			trace( "matchIndex : " + matchIndex );
			trace( "currentMusic : " + currentMusic );
			if (e.type == QuestionFinalMatch.MATCHDONE) {
				if (++matchIndex >= matches.length) {
					matchIndex = 0;
				}
				if (!musicSecond) {
					currentMatch = matches[matchIndex];
					musicSecond = true;
					playRound();
				} else {
					if (++currentMusic < 7) {
						currentMatch = matches[matchIndex];
						musicSecond = false;
						playRound();
					} else {
						currentMatch = null;
						bgMusicChannel.stop();
						//finalScoreMusic.playSound();
						finalScores();
					}
				}
			} else {
				matches.splice(matchIndex, 1);
				if (matches.length == 0 || ++currentMusic > 6) {
					currentMatch = null;
					bgMusicChannel.stop();
					//theWrongSound.stopSound();
					unsetButtons();
					finalScores()
					trace ("ROUND OVER");
					trace ("SCORE: " + _model.score);
					//matchOver();
				} else {
					if (matchIndex >= matches.length) {
						matchIndex = 0;
					}
					currentMatch = matches[matchIndex];
					addChild(currentMatch);
					playRound();
				}
			}
		}
		
		private function finalScores():void 
		{
			//finalScoreMusic.addEventListener(MP3Loader.SOUND_COMPLETE, endScream);
			//finalScoreMusic.playSound();
			finalVideoLoader.addChild(endVid.content);
			finalVideoLoader.alpha = 1;
			finalVideoLoader.visible = true;
			finalScoreMusic = new FinalScoreMusic();
			endVid.addEventListener(VideoLoader.VIDEO_COMPLETE, clearEnd);
			endVid.gotoVideoTime(0, true);
			bgMusicChannel = finalScoreMusic.play();
			bgMusicChannel.addEventListener(Event.SOUND_COMPLETE, endScream);
			TweenLite.delayedCall(5.4, showScore);
		}
		
		private function clearEnd(e:Event):void {
			finalVideoLoader.visible = false;
		}
		
		private function showScore():void {
			finalScore.score_txt.text = _model.scoreString;
			finalScore.visible = true;
		}
		
		private function endScream(e:Event):void {
			var i:uint = Math.floor(Math.random() * 4);
			var ScreamClass:Class = getDefinitionByName("Scream" + i.toString()) as Class;
			var scream:Sound = new ScreamClass();
			bgMusicChannel = scream.play();
			bgMusicChannel.addEventListener(Event.SOUND_COMPLETE, playTheme);
			//gameOver.addEventListener(MP3Loader.SOUND_COMPLETE, playTheme);
			//gameOver.gotoSoundTime(0, true);
		}
		
		private function playTheme(e:Event):void {
			var theme:Sound = new ThemeSong();
			bgMusicChannel = theme.play(0, 999);
			if (!endTheme) TweenLite.delayedCall(1, giveClosingThoughts);
		}
		
		private function giveClosingThoughts():void {
			var thoughtArr:Array = _model.preload.closingThought[0].MP3Loader;
			if (_model.score > 22000) {
				thought = _model.getLoader(thoughtArr[0].name);
				trace( "thoughtArr[0].name : " + thoughtArr[0].name );
			} else if (_model.score > 10000) {
				thought = _model.getLoader(thoughtArr[1].name);
				trace( "thoughtArr[1].name : " + thoughtArr[1].name );
			} else if (_model.score > 0) {
				thought = _model.getLoader(thoughtArr[2].name);
				trace( "thoughtArr[2].name : " + thoughtArr[2].name );
			} else if (_model.score == 0) {
				thought = _model.getLoader(thoughtArr[3].name);
				trace( "thoughtArr[3].name : " + thoughtArr[3].name );
			} else if (_model.score > -40000) {
				thought = _model.getLoader(thoughtArr[4].name);
				trace( "thoughtArr[4].name : " + thoughtArr[4].name );
			} else if (_model.score > -1000000) {
				thought = _model.getLoader(thoughtArr[5].name);
				trace( "thoughtArr[5].name : " + thoughtArr[5].name );
			} else {
				thought = _model.getLoader(thoughtArr[6].name);
				trace( "thoughtArr[6].name : " + thoughtArr[6].name );
			}
			
			thought.addEventListener(MP3Loader.SOUND_COMPLETE, showTitles)
			thought.gotoSoundTime(0, true);
		}
		
		private function showTitles (e:Event) {
			endTheme = true;
			bgMusicChannel.stop();
			var thunk:Sound = new ThunkEnd;
			bgMusicChannel = thunk.play();
			bgMusicChannel.addEventListener(Event.SOUND_COMPLETE, playTheme);
			finalScore.visible = false;
			finalLogo.visible = true;
			TweenLite.to(finalLogo, .7, { delay:2.785, scaleX: 7, scaleY:7, rotation: -20, ease:Strong.easeOut } );
			TweenLite.to(finalLogo, .3, { delay:3.185, alpha:.14, overwrite:false, onComplete:fadeInCreds } );
		}
		private function fadeInCreds() {
			
			for (var i:uint = 1; i < 5; i++) {
				credits["creds" + i.toString()].alpha = 0;
			}
			
			credits.visible = true;
			email.alpha = 0;
			email.visible = true;
			//TweenLite.to(credits, .4, { alpha:1, delay:1 } )
			
			var timeline:TimelineLite = new TimelineLite();
			timeline.insert(TweenLite.to(credits.creds1, .4, { alpha:1 } ));
			timeline.insert(TweenLite.to(credits.creds1, .4, { alpha:0 } ), 3.6);
			timeline.insert(TweenLite.to(credits.creds2, .4, { alpha:1 } ), 4);
			timeline.insert(TweenLite.to(credits.creds2, .4, { alpha:0 } ), 9.6);
			timeline.insert(TweenLite.to(credits.creds3, .4, { alpha:1 } ), 10);
			timeline.insert(TweenLite.to(email, .4, { alpha:1, delay:1.3, onComplete:setClick } ), 13);
			timeline.insert(TweenLite.to(credits.creds4, .4, { alpha:1 } ), 18);
			
			
			
		}
		
		private function setClick():void 
		{
			someTransform = new SoundTransform(1);
			dispatchEvent(new Event(ALLOWCLICK))
			email.addEventListener(MouseEvent.CLICK, sendEmail);
			email.addEventListener(MouseEvent.ROLL_OVER, scaleButton);
			email.addEventListener(MouseEvent.ROLL_OUT, scaleButton);
			TweenLite.to(someTransform, 5, { volume:0, delay:2, onUpdate:setChannel, onComplete:stopSound } );
		}
		
		private function setChannel():void {
			bgMusicChannel.soundTransform = someTransform;
		}
		
		private function stopSound():void 
		{
			bgMusicChannel.stop();
		}
			
		
		private function scaleButton(m:MouseEvent) {
			var scaleN:Number = (m.type == MouseEvent.ROLL_OVER) ? 1.1 : 1;
				TweenLite.killTweensOf(email);
				TweenLite.to(email, .2, { scaleX: scaleN, scaleY:scaleN } );
		}
		
		private function sendEmail(m:MouseEvent) {
			TweenLite.killTweensOf(email);
			navigateToURL(new URLRequest('mailto:mister@fardmuhammad.com?subject=I want to know Fard...'));
		}		
	}

}