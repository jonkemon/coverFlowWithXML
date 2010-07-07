package 
{
	import br.com.stimuli.loading.BulkLoader;
	import br.com.stimuli.loading.BulkProgressEvent;
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import gs.easing.Quint;
	import gs.TweenLite;
	import org.papervision3d.events.InteractiveScene3DEvent;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.view.BasicView;
	
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	
	/**
	 * ...
	 * @author Charlie Schulze, charlie[at]woveninteractive[dot]com
	 * Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
	 */
	
	public class Main extends BasicView 
	{
		protected var planes:Array = [];
		protected var images:Array = [];
		protected var numItems:Number;
		protected var currentItem:Number = 1;
		protected var angle:Number = 25;		
		protected var rightBtn:Sprite;
		protected var leftBtn:Sprite;
		protected var xmlPath:String = "http://media2.telecoms.com/loader_flash/speakerGalleryFlowBBWF/bin-release/xml/bbwfSpeakers.xml";
		protected var bulkInstance:BulkLoader;
		
		//TextFields For Speaker Info
		public var textName:TextField = new TextField;
		public var textTitle:TextField = new TextField;
		public var textCompany:TextField = new TextField;
		public var appTitle:TextField = new TextField;
		
		public var nameArray:Array = new Array;
		public var titleArray:Array = new Array;
		public var companyArray:Array = new Array;
		public var textContainer:MovieClip = new MovieClip;
		
		public function Main():void 
		{
			//Make sure that your scene is set to interactive
			super(259, 172, false, true);
			loadXML();
		}
		
		//First load our XML
		protected function loadXML():void 
		{
			bulkInstance = new BulkLoader("bulkInstance");			
			bulkInstance.add(xmlPath);
			bulkInstance.addEventListener(BulkProgressEvent.COMPLETE, onXMLReady);
			bulkInstance.start();
		}
		
		//When our xml is ready parse and load our images
		protected function onXMLReady(evt:BulkProgressEvent):void 
		{
			bulkInstance.removeEventListener(BulkProgressEvent.COMPLETE, onXMLReady);
			bulkInstance.addEventListener(BulkProgressEvent.COMPLETE, onImagesReady);
			
			var xml:XML = bulkInstance.getXML(xmlPath);
			var xmlList:XMLList = xml.speaker.imageurl;
			var xmlName:XMLList = xml.speaker.name;
			var xmlTitle:XMLList = xml.speaker.title;
			var xmlCompany:XMLList = xml.speaker.company;
			
			for (var i:int = 0; i < xmlList.length(); i++) 
			{
				var imagePath:String = String(xmlList[i])
				bulkInstance.add(imagePath);
				
				//Push name into Array
				var namePath:String = String(xmlName[i])
				nameArray.push(namePath);

				//Push name into Array
				var titlePath:String = String(xmlTitle[i])
				titleArray.push(titlePath);
				
				//Push name into Array
				var companyPath:String = String(xmlCompany[i])
				companyArray.push(companyPath);
				
				//Add path to array for later access
				images.push(imagePath);
			}
			
			//Set our number of items based on how many images we load
			numItems = images.length;
		}
		
		//Images are finished loading we can now create our papervision coverflow
		protected function onImagesReady(evt:BulkProgressEvent):void 
		{
			init();
		}
		
		protected function init():void 
		{
			createChildren();
			createNavigation();
			animate();
			startRendering();
		}
		protected function createChildren():void 
		{
			for (var i:int = 0; i < numItems; i++) 
			{
				//Grab our bitmapData from the bulkLoader using our array of image paths as our key
				var mat:BitmapMaterial 	= new BitmapMaterial(bulkInstance.getBitmapData(images[i]));
				mat.interactive 		= true;
				mat.smooth 				= true;
				var plane:Plane 		= new Plane(mat, 1.7);
				
				planes.push(plane);
				
				//Click straight to any plane
				plane.addEventListener(InteractiveScene3DEvent.OBJECT_PRESS, onPlaneClick);
				
				//Set an id to target current item
				plane.id = i;
				
				//Add plane to the scene
				scene.addChild(plane);
				
				//Create TextFields to display speaker details
				textName.htmlText = "Name of Speaker";
				textTitle.htmlText = "Title of Speaker";				
				textCompany.htmlText = "Company of Speaker";
				appTitle.htmlText = "Keynote Speakers 2010";
				
				//Format text
				var titleFormat:TextFormat = new TextFormat();
				titleFormat.size = 16;
				titleFormat.font = "Arial";
				titleFormat.bold = true;
				titleFormat.color = 0xFFFFFF;
				titleFormat.align = TextFormatAlign.CENTER;				
				
				var nameFormat:TextFormat = new TextFormat();
				nameFormat.size = 12;
				nameFormat.bold = true;
				nameFormat.font = "Arial";
				nameFormat.color = 0x333333;
				nameFormat.align = TextFormatAlign.CENTER;
				
				var standardFormat:TextFormat = new TextFormat();
				standardFormat.size = 12;
				standardFormat.font = "Arial";
				standardFormat.color = 0x333333;
				standardFormat.align = TextFormatAlign.CENTER;
				
				textName.defaultTextFormat = nameFormat;
				textTitle.defaultTextFormat = standardFormat;
				textCompany.defaultTextFormat = standardFormat;
				appTitle.defaultTextFormat = titleFormat;
				
				//Add TextContainer to Stage
				stage.addChild(textContainer);
				textContainer.x = 36;
				
				//Add to stage
				stage.addChild(appTitle);
				appTitle.y = 4;
				appTitle.x = 25;
				appTitle.width = 208;
				appTitle.height = 25;
				appTitle.selectable = false;
				
				textContainer.addChild(textName);
				textName.y = 150;
				textName.width = 190;
				textName.selectable = false;
				
				textContainer.addChild(textTitle);
				textTitle.y = 164;
				textTitle.width = 190;
				textTitle.selectable = false;
				
				textContainer.addChild(textCompany);
				textCompany.y = 177;
				textCompany.width = 200;
				textCompany.selectable = false;
			}
			
			camera.zoom = 50;
		}
		
		protected function onPlaneClick(evt:InteractiveScene3DEvent):void 
		{
			currentItem = evt.target.id;
			animate();
		}
		
		//Animate the coverflow left / right based off of currentItems
		protected function animate():void 
		{
			for (var i:int = 0; i < planes.length; i++) 
			{
				var plane:Plane = planes[i];
				
				//Each if statement will adjust these numbers as needed
				var planeX:Number = 0;
				var planeZ:Number = -50;
				var planeRotationY:Number = 0

				//Place  & Animate Center Item
				if (i == currentItem) 
				{
					planeZ 				= -300
					
					TweenLite.to(plane, 1, { rotationY:planeRotationY,x:planeX,z:planeZ, ease:Quint.easeInOut } );
					textName.htmlText = nameArray[currentItem] as String;
					textTitle.htmlText = titleArray[currentItem] as String;
					textCompany.htmlText = companyArray[currentItem] as String;
				} 
				
				//Place & Animate Right Items
				if(i > currentItem)  
				{
					planeX 				= (i - currentItem + 1) * 120;
					planeRotationY 		= angle + 10 * (i - currentItem);
					
					TweenLite.to(plane, 1, { rotationY:planeRotationY,x:planeX,z:planeZ, ease:Quint.easeInOut } );
				}
				
				//Place & Animate Left Items
				if (i < currentItem) 
				{
					planeX 				= (currentItem - i + 1) * -120;
					planeRotationY 		= -angle - 10 * (currentItem - i);
					
					TweenLite.to(plane, 1, { rotationY:planeRotationY,x:planeX,z:planeZ, ease:Quint.easeInOut } );
				}
			}
		}
		
		/*
		 * Everything below this point is just for creating the buttons and
		 * setting button events for controlling the coverflow. 
		 */

		protected function createNavigation():void 
		{
			//Create / Add Buttons
			rightBtn = createButton();
			leftBtn = createButton();
				
			addChild(leftBtn);
			addChild(rightBtn);
			
			//Add button listeners
			rightBtn.buttonMode = true;
			leftBtn.buttonMode = true;
			rightBtn.addEventListener(MouseEvent.CLICK, buttonClick);
			leftBtn.addEventListener(MouseEvent.CLICK, buttonClick);
						
			//Place buttons on stage
			rightBtn.x 			= stage.stageWidth - 20;
			leftBtn.x 			= 20;
			rightBtn.y 			= 164;
			leftBtn.y 			= 183;
			leftBtn.rotation 	= 180;
		}
		
		//Button actions
		protected function buttonClick(evt:MouseEvent):void 
		{
			switch (evt.target)
			{
				case rightBtn:
				currentItem ++
				break;
				
				case leftBtn:
				currentItem --;
				break;
			}
			
			//Don't allow any number lower than 0 or past max so there
			//is always a center item
			
			if (currentItem < 0)
			{
				currentItem = 0;
			}
			if (currentItem > (planes.length - 1))
			{
				currentItem = planes.length - 1;
			}
			
			//Call animation
			animate();
		}
		
		//Creates a simple arrow shape / returns the sprite
		protected function createButton():Sprite
		{
			var btn:Sprite = new Sprite();
			
			btn.graphics.beginFill(0x333333);
			btn.graphics.moveTo(0, 0);
			btn.graphics.lineTo(0, 20);
			btn.graphics.lineTo(10, 10);
			btn.graphics.lineTo(0, 0);
			btn.graphics.endFill();
			btn.filters = [new GlowFilter(0xFFFFFF,1,10,10,3)]
			return btn;
		}
	}
}