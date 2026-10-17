package;

import flixel.FlxState;
import flixel.FlxG;

import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import flixel.system.FlxSound;
import openfl.utils.Assets;
import openfl.utils.AssetType;

import openfl.Lib;

using StringTools;

class VideoState extends MusicBeatState
{
	public var leSource:String = "";
	public var transClass:FlxState;
	public var txt:FlxText;
	public var fuckingVolume:Float = 1;
	public var notDone:Bool = true;
	public var defaultText:String = "";
	public var pauseText:String = "Press P To Pause/Unpause";

	public function new(source:String, toTrans:FlxState)
	{
		super();
		
		leSource = source;
		transClass = toTrans;
	}
	
	override function create()
	{
		super.create();
		FlxG.autoPause = false;

		fuckingVolume = FlxG.sound.music.volume;
		FlxG.sound.music.volume = 0;
		var isHTML:Bool = false;
		#if web
		isHTML = true;
		#end
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		txt = new FlxText(0, 0, FlxG.width,
			defaultText,
			32);
		txt.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		txt.screenCenter();
		add(txt);

		GlobalVideo.get().source(leSource);
		GlobalVideo.get().clearPause();
		if (GlobalVideo.isWebm)
		{
			GlobalVideo.get().updatePlayer();
			#if !web
			// FlxVideoSprite 是 FlxSprite，add 进状态树走 flixel 渲染管线
			add(GlobalVideo.getWebm().video);
			#end
		}
		GlobalVideo.get().show();
		GlobalVideo.get().play();
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (notDone)
		{
			FlxG.sound.music.volume = 0;
		}
		GlobalVideo.get().update(elapsed);

		if (controls.RESET)
		{
			GlobalVideo.get().restart();
		}
		
		if (FlxG.keys.justPressed.P)
		{
			txt.text = pauseText;
			trace("PRESSED PAUSE");
			GlobalVideo.get().togglePause();
			if (GlobalVideo.get().paused)
			{
				GlobalVideo.get().alpha();
			} else {
				GlobalVideo.get().unalpha();
				txt.text = defaultText;
			}
		}
		
		if (controls.ACCEPT || GlobalVideo.get().ended || GlobalVideo.get().stopped)
		{
			txt.visible = false;
			GlobalVideo.get().hide();
			GlobalVideo.get().stop();
		}
		
		if (controls.ACCEPT || GlobalVideo.get().ended)
		{
			notDone = false;
			FlxG.sound.music.volume = fuckingVolume;
			txt.text = pauseText;
			FlxG.autoPause = true;
			FlxG.switchState(transClass);
		}
		
		if (GlobalVideo.get().played || GlobalVideo.get().restarted)
		{
			GlobalVideo.get().show();
		}
		
		GlobalVideo.get().restarted = false;
		GlobalVideo.get().played = false;
		GlobalVideo.get().stopped = false;
		GlobalVideo.get().ended = false;
	}
}