package  
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.SampleDataEvent;
	import flash.media.Sound;
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author Fard Muhammad
	 */
	public class MP3Loop extends Sprite
	{
		//This class is based on the code found here: http://blog.andre-michelle.com/2010/playback-mp3-loop-gapless/
		//The background music that repeats needs to be gapless in order for it to sound well.
		
		private const MAGIC_DELAY:Number = 2257.0 //LAME + flash.media.Sound Delay
		private const bufferSize:int = 4096;
		private var  _samplesTotal:int = 124417 // Will need to change this for the loop.
		private const mp3:Sound = new Sound();
		private const out:Sound = new Sound();
		private var _soundByte:ByteArray;
		
		private var _model:JackModel;
		private var _command:JackCommand;
		
		private static var _instance:MP3Loop;
		
		public static function getInstance():MP3Loop {
			if (_instance == null) _instance = new MP3Loop();
			return _instance;
		}
		
		private var samplesPosition: int = 0;
		private var _current_snd:Sound;
		
		
		public function MP3Loop() 
		{
		}
		
		public function init() {
			trace ("Sound initialized");
			removeEventListener(Event.ADDED_TO_STAGE, init);
			_model = JackModel.getInstance();
			_command = JackCommand.getInstance();
		}
		
		public function loadMP3(currentSound:Sound):void {
			_current_snd = currentSound;
			out.addEventListener(SampleDataEvent.SAMPLE_DATA, sampleData);
			out.play();
		}
		
		private function sampleData(event:SampleDataEvent):void {
		
		}
	}

}