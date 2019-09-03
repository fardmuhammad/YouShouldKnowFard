package  
{
	import com.greensock.easing.Back;
	import com.greensock.TweenLite;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Fard Muhammad
	 */
	public class Score extends MovieClip
	{
		private var _model:JackModel;
		private var _command:JackCommand;
		public var scoreMultChoice:MovieClip;
		private var defaultTF:TextFormat;
		private var rightTF:TextFormat;
		private var wrongTF:TextFormat;
		
		private var currentScore:int = 0;
		
		public function Score() 
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event) {
			_model = JackModel.getInstance();
			_command = JackCommand.getInstance();
			_command.addEventListener(JackCommand.SHOWSCORE, showScore);
			_command.addEventListener(JackCommand.HIDESCORE, hideScore);
			_model.addEventListener(JackModel.RIGHTANSWER, rightAnswer);
			_model.addEventListener(JackModel.WRONGANSWER, wrongAnswer);
			
			defaultTF = scoreMultChoice.score_txt.getTextFormat();
			rightTF = new TextFormat();
			rightTF.color = 0x00CC00;
			wrongTF = new TextFormat();
			wrongTF.color = 0x990000;
			scoreMultChoice.score_txt.alpha = 0;
		}
		
		
		private function wrongAnswer(e:Event):void 
		{
			setScoreText();
			scoreMultChoice.score_txt.setTextFormat(wrongTF);
		}
		
		private function rightAnswer(e:Event):void 
		{
			setScoreText();
			scoreMultChoice.score_txt.setTextFormat(rightTF);
		}

		private function hideScore(e:Event):void 
		{
			scoreMultChoice.y = 680;
			scoreMultChoice.score_txt.setTextFormat(defaultTF);
			scoreMultChoice.score_txt.alpha = 0;
		}
		
		private function showScore(e:Event):void 
		{
			scoreMultChoice.score_txt.setTextFormat(defaultTF);
			TweenLite.to(scoreMultChoice, .8, { y:575, ease:Back.easeOut } );
			TweenLite.to(scoreMultChoice.score_txt, .3, { alpha:1, delay:.5, onComplete:startQuestion } );
		}
		
		private function setScoreText():void 
		{
			scoreMultChoice.score_txt.text = _model.scoreString//((_model.score < 0) ? ("-$") : ("$")) + (Math.abs(_model.score).toString());
			//trace( "_model.score < 0 : " + (_model.score < 0) );
		}
		
		private function startQuestion():void 
		{
			_command.startQuestion();
		}
		
		
	}

}