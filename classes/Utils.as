package  
{
	import flash.text.TextField;
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author Fard Muhammad
	 */
	public class Utils
	{
		
		public function Utils() 
		{
			
		}
		
		public static function scaleTextToFit(_txtField:TextField, minSize:uint, numLines:uint = 2) {
			var tf:TextFormat = _txtField.getTextFormat();
			var textSize:uint = uint(tf.size);
			
			while (_txtField.maxScrollV > 1 && textSize > minSize) {
				textSize = textSize - 1;
				tf.size = textSize;
				_txtField.setTextFormat(tf);
			}
		}
		
	}

}