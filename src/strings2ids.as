package
{
	
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.desktop.NativeDragManager;
	import flash.display.InteractiveObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.NativeDragEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	
	/**
	 * 
	 * @author Rect  2013-4-16 
	 * 
	 */
	[SWF(width="800" , height="600")]
	public class strings2ids extends Sprite 
	{ 
		private var sp:Sprite;
		private var mapAry:Array = [];
		private var test:TextField;
		private var beginBtn:backButton;
		private var clearBtn:backButton;
		private var textSize:TextField;
		private var textQuality:TextField;
		private var fileObj:FileReference = new FileReference();
		private var stringXMLPath:File = null;
		private var stringXMLPath_output:File = null;
		
		public function strings2ids()
		{
			super();
			init();
		} 
		private function init():void{
			sp = new Sprite();
			test = new TextField();
			test.defaultTextFormat = (new TextFormat("",18,0x708360));
			test.text = "请将res文件夹拖入此处";
			test.width = 800;
			test.height = 520;
			test.wordWrap = true;
			test.multiline = true;
			test.background = true;
			test.backgroundColor = 0x393939;
			
			sp.addChild(test);
			sp.graphics.beginFill(0x313335);
			sp.graphics.drawRect(0,0,800,600);
			sp.graphics.endFill();
			this.addChild(sp);
			sp.addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER, onDragInHandler);
			sp.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP, onDropHandler);
			
			
			beginBtn = new backButton("开始");
			beginBtn.x = 600,beginBtn.y = 540;
			beginBtn.mouseEnabled = false;
			beginBtn.addEventListener(MouseEvent.CLICK,onClick);
			this.addChild(beginBtn);
			
			clearBtn = new backButton("清空");
			clearBtn.x = 400,clearBtn.y = 540;
			clearBtn.addEventListener(MouseEvent.CLICK,onClearClick);
			this.addChild(clearBtn);
			
			
			updateStatus();
			
			
		}
		
		
		private var stringXML:XML;
		private var miscXML:XML;
		private function HandleMaps(onOver:Function):void{
			var mLoaderImages:URLLoader = new URLLoader();
			var fun:Function = function(evt:Event):void{
				mLoaderImages.removeEventListener(Event.COMPLETE,fun);
				stringXML = XML(mLoaderImages.data);
				if( onOver != null )
					onOver();
			};
			mLoaderImages.addEventListener(Event.COMPLETE,fun);
			mLoaderImages.load(new URLRequest( stringXMLPath.url));
		}
		
		
		/**********************************/
		private function onClick(ev:MouseEvent):void{
			test.appendText("\n\n修改进行中..");
			this.beginBtn.mouseEnabled = false;
			HandleMaps(function():void
			{
				HandleMap();
			});
		}
		
		private function updateStatus():void
		{
			if( motherFileAry.length == 0 )
			{
				beginBtn.setText("请将res拖入此程序");
			}
			else
			{
				beginBtn.setText("处理" + motherFileAry.length + "个文件");
			}
			
		}
		private function onClearClick(ev:MouseEvent):void{
			
			test.text =  "请将res文件夹拖入此处";
			
			while( motherFileAry.length ) motherFileAry.pop();
			while( sonFileAry.length ) sonFileAry.pop();
			
			stringXMLPath = null;
			stringXMLPath_output = null;
			
			updateStatus();
			this.beginBtn.mouseEnabled = false;
		}
		
		
		
		private function textDown(ev:MouseEvent):void{
			var text:TextField = ev.currentTarget as TextField;
			text.text = "";
		}
		protected function onDragInHandler(event : NativeDragEvent) : void
		{
			var transferable :Clipboard = event.clipboard;
			if(transferable.hasFormat(ClipboardFormats.FILE_LIST_FORMAT))
			{
				var files : Array = transferable.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;
				if(files)
				{
					var file : File = File(files[0]);
					
					if(file && file.isDirectory && file.name == "res" 
						&& file.resolvePath("layout").exists
						&& file.resolvePath("values").exists
					)
					{
						NativeDragManager.acceptDragDrop(event.currentTarget as InteractiveObject);
					}
					else
					{
						test.appendText("\n请拖入正确的res文件夹");
					}
				}
				
			}
		}
		
		private var motherFileAry:Array = [];
		private var sonFileAry:Array = [];
		private var xmlHead:String = '<?xml version="1.0" encoding="utf-8" ?>';
		protected function onDropHandler(event : NativeDragEvent) : void
		{
			motherFileAry = [];
			sonFileAry = [];
			var transferable :Clipboard = event.clipboard;
			var files : Array = transferable.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;
			if(files)
			{
				var file :File;
				for(var t:int = 0;t<files.length;t++){
					file  = File(files[t]);
					test.appendText("\n"+file.url);
					
					var inputPath:File = file.resolvePath("layout");
					var outputPath:File = file.resolvePath("../output/");
					var stringFile:File = file.resolvePath("values");
					
					if( outputPath.exists )
						outputPath.deleteDirectory(true);
					outputPath.createDirectory();
					
					var olayoutPath:File = outputPath.resolvePath("layout");
					if( !olayoutPath.exists ) olayoutPath.createDirectory();
					
					var ovaluePath:File = outputPath.resolvePath("values");
					if( !ovaluePath.exists ) ovaluePath.createDirectory();
					
					test.appendText("\n\nlayout输出路径\n" + olayoutPath.url);
					
					if( inputPath != null )
					{
						var inputs:Array = inputPath.getDirectoryListing();
						for( var j:int = 0 ; j < inputs.length ;j ++)
						{
							var tmp:File = inputs[j];
							motherFileAry.push(tmp.url);
							sonFileAry.push(olayoutPath.url+"/"+ tmp.name);
						}
					}
					
					if( stringFile != null  )
					{
						var xmlFiles:Array = stringFile.getDirectoryListing();
						var isFind:Boolean = false;
						for( var k:int = 0 ; k < xmlFiles.length ; k++ )
						{
							stringXMLPath = xmlFiles[k];
							
							if( stringXMLPath.name.indexOf("strings") != -1 )
							{
								isFind = true;
								stringXMLPath_output = ovaluePath.resolvePath(stringXMLPath.name);
								test.appendText("\n\nstrings.xml输出路径\n" + stringXMLPath_output.url);
								break;
							}
						}
						if( !isFind ) stringXMLPath = null;
					}
					
				}
				if(sonFileAry.length != 0 && stringXMLPath != null )
				{
					this.beginBtn.mouseEnabled = true;
					updateStatus();
				}
				
				//trace(motherFileAry,outPath);//(file.name.length - 4))));
			}
		}
		
		private var _loaderImage:URLLoader  = new URLLoader();
		private function HandleMap():void{
			if(motherFileAry.length)
			{
				_loaderImage.addEventListener(Event.COMPLETE,loaderInitListener);
				_loaderImage.load(new URLRequest(motherFileAry.pop()));
			}
			else
			{
				test.text = ("完成！");
				makeValue();
			}
		}
		
		private function makeValue():void
		{
			
			for(var t:int = 0;t<stringArr.length;t++)
			{
				stringXML.appendChild(<string name = {stringName[t]}>{stringArr[t]}</string>);
			}
			
			//var filePath:String = stringXMLPath;
			var f:FileStream = new FileStream();
			var fl:File = new File(stringXMLPath_output.url);
			
			f.open(fl,FileMode.WRITE);
			var xmlStr1:String = stringXML.toString();
			var pattern1:RegExp = /\n/g;
			xmlStr1=xmlStr1.replace(pattern1, "\r\n");
			f.writeUTFBytes(String(xmlHead+"\r\n"+ xmlStr1));
			f.close();
			
			
		}
		
		private function loaderInitListener(evt:Event):void {
			
			_loaderImage.removeEventListener(Event.COMPLETE,loaderInitListener);
			
			var xml:XML = XML(_loaderImage.data);
			
			walk(xml);
			
			makeFile(xml);
			
			HandleMap();
		}
		
		
		private function makeFile(str:XML):void{
			
			var filePath:String = (sonFileAry.pop()) ;
			var f:FileStream = new FileStream();
			var fl:File = new File(filePath);
			
			f.open(fl,FileMode.WRITE);
			
			var xmlStr:String = str.toXMLString();
			var pattern:RegExp = /\n/g;
			xmlStr=xmlStr.replace(pattern, "\r\n");
			f.writeUTFBytes(String(xmlHead+"\r\n"+ xmlStr));
			
			f.close();
			
		}
		
		private var stringArr:Array = [];
		private var stringName:Array = [];
		private var stringLen:int = 0;
		
		
		namespace ns = "http://schemas.android.com/apk/res/android"
		use namespace ns; 
		
		
		
		private function walk( node:XML ):void {
			
			var text:String =  node["@text"];
			if( text != null &&  text.length > 0 )
			{
				if( text.charAt(0) != "@" )
				{
					stringArr.push(text);
					stringName.push("DW_string_" + stringLen);
					
					node["@text"] = "@string/DW_string_" + stringLen.toString();
					
					stringLen++;
				}
			}
			for each ( var element:XML in node.elements( ) ) 
			{
				walk(element);
			}
		}
	}
}


import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

class backButton extends Sprite
{
	private var _buttonName:String;
	private var _szWide:Number;
	private var _szHeight:Number;
	private var _Color:int;
	public function backButton(
		buttonName:String,
		szWide:Number = 180,
		szHeight:Number = 40,
		Color:int = 0xFFFFFF)
	{
		_buttonName = buttonName;
		_szWide = szWide;
		_szHeight = szHeight;
		_Color = Color;
		init();
	}
	private var _text:TextField;
	private var _textFormat:TextFormat;
	private function init():void{
		_text = new TextField();
		_text.mouseEnabled = false;
		_text.text = _buttonName;
		_text.width = _szWide;
		_text.autoSize = TextFieldAutoSize.LEFT;
		_textFormat = new TextFormat();
		_textFormat.size = 18;
		_textFormat.font = "微软雅黑";
		_textFormat.color = 0;//0x228b22;
		_text.setTextFormat(_textFormat);
		_text.y = ( _szHeight -   _text.height )/2;
		_text.x = ( _szWide -   _text.width )/2;
		
		addChild(_text);
		this.graphics.beginFill(_Color,.9);
		this.graphics.drawRoundRect(0,0,_szWide,_szHeight,0,0);
		this.graphics.endFill();
		this.addEventListener(MouseEvent.ROLL_OVER,onMouseOver);
		this.addEventListener(MouseEvent.ROLL_OUT,onMouseOut);
	}
	public function setText(text:String):void
	{
		_text.text = text;
		_text.setTextFormat(_textFormat);
		_text.y = ( _szHeight -   _text.height )/2;
		_text.x = ( _szWide -   _text.width )/2;
	}
	private function onMouseOut(ev:MouseEvent):void{
		this.graphics.clear();
		this.graphics.beginFill(_Color,.9);
		this.graphics.drawRoundRect(0,0,_szWide,_szHeight,0,0);
		this.graphics.endFill();
	}
	private function onMouseOver(ev:MouseEvent):void{
		this.graphics.clear();
		this.graphics.beginFill(0x708360,.9);
		this.graphics.drawRoundRect(1,1,_szWide-1,_szHeight-1,0,0);
		this.graphics.endFill();
	}
}
