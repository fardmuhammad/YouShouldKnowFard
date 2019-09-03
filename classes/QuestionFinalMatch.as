package  
{
	import com.greensock.easing.Linear;
	import com.greensock.easing.Quad;
	import com.greensock.easing.Strong;
	import com.greensock.TimelineLite;
	import com.greensock.TweenLite;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.text.TextFieldAutoSize;
	import flash.ui.Keyboard;
	
	/**
	 * ...
	 * @author Fard Muhammad
	 */
	public class QuestionFinalMatch extends MovieClip
	{
		private var _matchData:Object;
		private var _title:String;
		private var _choices:Array;
		private var currentChoice:String = "";
		private const NUMWORDS:uint = 7;
		private var _rightAnswer:String;
		static public const RIGHT:String = "right";
		static public const MATCHDONE:String = "matchdone";
		static public const MATCHWIN:String = "matchwin";
		static public const MUSICSTOP:String = "musicStop";
		static public const WRONG:String = "wrong";
		private var usedTextArr:Array = [false, false, false, false];
		private var currentText:uint;
		private var timeline:TimelineLite;
		
		private var _model:JackModel
		
		public var match1:MovieClip;
		public var match2_0:MovieClip;
		public var match2_1:MovieClip;
		public var match2_2:MovieClip;
		public var match2_3:MovieClip;
		public var match3:MovieClip;
		public var match4:MovieClip;
		
		private const LEFT:Number = 184.95;
		private const RIGHT:Number = 622.95;
		private const TOP:Number = 129.70;
		private const BOTTOM:Number = 477.70;
		public var rightMoney:MovieClip;
		public var wrongMoney:MovieClip;
		
		public var acceptKeyStrokes:Boolean = false;
		
		public function QuestionFinalMatch(matchData:Object) 
		//public function QuestionFinalMatch() 
		{
			_model = JackModel.getInstance();
			timeline = new TimelineLite();
			_matchData = matchData;
			_title = _matchData.title[0].nodeValue;
//			_title = "My e-mail address is..."
			_choices = new Array();
			
//			_choices = 	["mister@fardmuhammad.com", "fard@altavista.com", "ford@infoseek.com", "lenosucks@rocketmail.com", "atarifan@geocities.com", "Trick Question- I don't use e-mail", "4WayJack@jellyvision.org"];
				
			
			for (var i:uint = 0; i < NUMWORDS; i++) {
				_choices.push(_matchData.phrase[i].nodeValue);
			}
			_rightAnswer = _choices[0];
			
			//trace (_title + "\n" + _choices + "\n-------------")
			
			//reset();
			for (i = 0; i < 4; i++) {
				this["match2_" + i].alpha = 0;
			}
			//startText();
		}
		
		public function reset() {
			//randomize choices
			
			var temp:String;
			var rand:uint;
			for (var i:uint = 0; i < NUMWORDS; i++) {
				rand = Math.floor(Math.random() * 7);
				temp = _choices[rand];
				_choices[rand] = _choices[i];
				_choices[i] = temp;
			}
			
			match1.match_txt.text = _title;
			match3.match_txt.text = _title;
			Utils.scaleTextToFit(match1.match_txt, 42);
			Utils.scaleTextToFit(match3.match_txt, 42);
			match1.scaleX = match1.scaleY = .4;
			match1.y = 306.4;
			match1.alpha = 0
			match4.answer_txt.text = _rightAnswer;
			match4.visible = false;
			match3.visible = false;
			rightMoney.visible = false;
			rightMoney.alpha = 0;
			wrongMoney.alpha = 0;
			Utils.scaleTextToFit(match4.answer_txt, 36);
			

		}
		
		private function resetText(i:uint) {
			var mc:MovieClip = this["match2_" + i.toString()];
			mc.alpha = 0;
			//trace( "mc.alpha : " + mc.alpha );
			mc.x = (i % 2) ? RIGHT : LEFT;
			//trace( "mc.x : " + mc.x );
			mc.y = (i < 2) ? TOP : BOTTOM;
			//trace( "mc.y : " + mc.y + "\n");
			mc.scaleX = mc.scaleY = 1;
			
			//mc.match2_txt.text = " ";
			mc.match2_txt.height = 74.55;
			mc.match2_txt.y = -37.25;
			mc.match2_txt.autoSize = TextFieldAutoSize.NONE;
		}
		
		public function startText(duration:Number) {
			reset();
			stage.focus = stage;
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKey);
			if (timeline) { 
				timeline.kill(); 
				timeline.clear(); 
			}
			timeline = new TimelineLite();
			timeline.timeScale = 12 / (duration * 2);
			var whichText:uint 
/*			for (var i:uint = 0; i < 4; i++) {
				whichText = setUnused();
				//trace( "whichText : " + whichText );
				setText(whichText, _choices[i]);
			}
*/			
			timeline.insert(TweenLite.to(match1, 11.4, { scaleX:1, scaleY:1, ease:Quad.easeOut } ));
			timeline.insert(TweenLite.to(match1, .6, { alpha:1 } ));
			timeline.insert(TweenLite.to(match1, .6, { scaleX:.5, scaleY:.5, y:700 } ), 11.4);
			
			goQuestion(0);
			
			
			//if (++currentChoice == NUMWORDS) dispatchEvent(new Event(MATCHDONE));
		}
		
		private function goQuestion(qNum:uint) {
			var whichText:uint = setUnused();
			currentChoice = _choices[qNum];
			resetText(whichText);
			var whichMC:MovieClip = setText(whichText, _choices[qNum]);
			//trace( "whichMC : " + whichMC.name );
			timeline.insert(TweenLite.to(whichMC, .2, { alpha:1, onStart:setKeys } ), 1.5 * (qNum + 1));
			timeline.insert(TweenLite.to(whichMC, .6, { x: 400, ease: Quad.easeOut, onComplete: nextChoice, onCompleteParams:[qNum, whichText]} ), 1.5 * (qNum + 1) + .9);
			timeline.insert(TweenLite.to(whichMC, .6, { y: 300, scaleX: 0, scaleY:0 } ), 1.5 * (qNum + 1) + .9);
		}
		
		private function setKeys() {
			if (!acceptKeyStrokes) {
				//trace ("keyStrokesOn");
				acceptKeyStrokes = true;
			}
		}
		
		private function nextChoice(qNum:uint, which:uint) {
			//resetText(which);
			if (++qNum < NUMWORDS) {
				goQuestion(qNum);
			} else {
				//startText();
				acceptKeyStrokes = false;
				dispatchEvent(new Event(MATCHDONE))
			}
		}
		
		private function setUnused():uint 
		{
			var rand:uint = Math.floor(Math.random() * 4);
			while (usedTextArr[rand]) {
				rand = Math.floor(Math.random() * 4)
			}
			usedTextArr[rand] = true;
			var isMore:Boolean = false;
			for (var i:uint = 0; i < 4; i++) {
				if (!usedTextArr[i]) {
					isMore = true;
					break;
				}
			}
			if (!isMore) {
				for (i = 0; i < 4; i++) {
					resetText(i);
					usedTextArr[i] = false;
				}
				usedTextArr[rand] = true;
			}
			return rand;
			
		}
		
		private function setText(i:uint, _text:String):MovieClip {			
			var mc:MovieClip = this["match2_" + i.toString()];
			//trace( "mc : " + mc.name );
			mc.match2_txt.text = _text;
			Utils.scaleTextToFit(mc.match2_txt, 18);
			mc.match2_txt.y = mc.match2_txt.textHeight / -2
			return mc;
		}
		
		private function onKey(k:KeyboardEvent) {
			if (k.charCode == Keyboard.SPACE) {
				onSpaceBar();
			}
		}
		public function onSpaceBar() {
			if (acceptKeyStrokes) {
				//trace (currentChoice);
				if (currentChoice == _rightAnswer) {
					stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKey);
					timeline.stop();
					match1.visible = false;
					match2_0.visible = false;
					match2_1.visible = false;
					match2_2.visible = false;
					match2_3.visible = false;
					match3.visible = true;
					match4.visible = true;
					rightMoney.visible = true;
					rightMoney.alpha = 0;
					dispatchEvent(new Event(MUSICSTOP));
					TweenLite.to(match3, .3, { x:"800", easing:Linear.easeInOut, delay:1 } );
					TweenLite.to(match4, .3, { x:"-800", easing:Linear.easeInOut, delay:1 } );
					TweenLite.to(rightMoney, 1, { scaleX:1.25, scaleY:1.15, easing:Linear.easeInOut, delay:1.15});
					TweenLite.to(rightMoney, .4, { alpha:1, delay:1.15, overwrite:false } );
					TweenLite.to(rightMoney, .4, { alpha:0, delay:1.75, overwrite:false, onComplete:winRound } );
					_model.rightFinal();
					
				} else {
					dispatchEvent(new Event(WRONG));
					TweenLite.killTweensOf(wrongMoney);
					wrongMoney.alpha = 1;
					wrongMoney.scaleX = wrongMoney.scaleY = 1.2;
					TweenLite.to(wrongMoney, .6, { alpha:0, scaleX:1, scaleY:1 } );
					_model.wrongFinal();
				}
			}
		}
		
		private function winRound():void 
		{
			dispatchEvent(new Event(MATCHWIN));
		}
	}

}