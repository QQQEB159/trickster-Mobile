package;

import flixel.FlxG;
import openfl.display.Sprite;
#if !web
import hxvlc.flixel.FlxVideo;
#end

/**
 * hxvlc 视频适配层（替代原 webm extension 实现）
 * - 桌面端 / 移动端统一使用 hxvlc.flixel.FlxVideo 播放（VLC 内核，支持 webm/mp4）
 * - FlxVideo 渲染在游戏顶层，需挂到 FlxG.game 显示列表，不能进 FlxState 树
 * - web 端保留占位（web 目标继续走 VideoHandler/NetStream）
 */
class WebmHandler
{
	#if !web
	public var video:FlxVideo;
	public var vidPath:String = "";
	public var initialized:Bool = false;

	public var stopped:Bool = false;
	public var restarted:Bool = false;
	public var played:Bool = false;
	public var ended:Bool = false;
	public var paused:Bool = false;

	public function new():Void {}

	public function source(?vPath:String):Void
	{
		if (vPath != null && vPath.length > 0)
		{
			vidPath = vPath;
		}
	}

	/** 创建 hxvlc 播放器（全局初始化一次；VideoState 每次换源走 updatePlayer） */
	public function makePlayer():Void
	{
		if (initialized) return;

		video = new FlxVideo();
		video.onEndReached.add(function()
		{
			onEnd();
		});
		video.visible = false;
		FlxG.game.addChild(video);

		initialized = true;
	}

	/** 加载 / 切换视频源 */
	public function updatePlayer():Void
	{
		if (!initialized) makePlayer();
		if (vidPath.length <= 0) return;

		stopped = false;
		restarted = false;
		played = false;
		ended = false;
		paused = false;

		video.load(vidPath);
	}

	public function play():Void
	{
		if (initialized && video != null)
		{
			video.play();
			played = true;
		}
	}

	public function stop():Void
	{
		if (initialized && video != null)
		{
			video.stop();
			stopped = true;
		}
	}

	public function restart():Void
	{
		if (initialized && video != null)
		{
			video.stop();
			video.play();
			restarted = true;
		}
	}

	public function update(elapsed:Float):Void
	{
		if (!initialized || video == null) return;

		// FlxVideo 挂在 FlxG.game 下，坐标系是 flixel 逻辑坐标（FlxG.width/height），
		// 不能用 GlobalVideo.calc 的 stage 物理像素，否则全面屏/缩放下会偏移。
		// 这里直接用逻辑分辨率做 letterbox 居中，与分辨率/缩放脱钩。
		var ratioX:Float = GameDimensions.height / GameDimensions.width;
		var ratioY:Float = GameDimensions.width / GameDimensions.height;
		var appliedWidth:Float = FlxG.height * ratioY;
		var appliedHeight:Float = FlxG.width * ratioX;
		var remainingX:Float = (FlxG.width - appliedWidth) / 2;
		var remainingY:Float = (FlxG.height - appliedHeight) / 2;

		if (appliedHeight > FlxG.height)
		{
			remainingY = 0;
			appliedHeight = FlxG.height;
		}
		if (appliedWidth > FlxG.width)
		{
			remainingX = 0;
			appliedWidth = FlxG.width;
		}

		video.x = remainingX;
		video.y = remainingY;
		video.width = appliedWidth;
		video.height = appliedHeight;
	}

	public function pause():Void
	{
		if (initialized && video != null) video.pause();
		paused = true;
	}

	public function resume():Void
	{
		if (initialized && video != null) video.resume();
		paused = false;
	}

	public function togglePause():Void
	{
		if (paused) resume() else pause();
	}

	public function clearPause():Void
	{
		paused = false;
		if (initialized && video != null) video.resume();
	}

	public function onStop():Void { stopped = true; }
	public function onRestart():Void { restarted = true; }
	public function onPlay():Void { played = true; }
	public function onEnd():Void { ended = true; }

	public function alpha():Void { video.alpha = GlobalVideo.daAlpha1; }
	public function unalpha():Void { video.alpha = GlobalVideo.daAlpha2; }
	public function hide():Void { video.visible = false; }
	public function show():Void { video.visible = true; }
	#else
	public var webm:Sprite;

	public var stopped:Bool = false;
	public var restarted:Bool = false;
	public var played:Bool = false;
	public var ended:Bool = false;
	public var paused:Bool = false;

	public function new():Void
	{
		trace("hxvlc 不支持 web 目标，请使用 VideoHandler");
	}

	public function source(?vPath:String):Void {}
	public function makePlayer():Void {}
	public function updatePlayer():Void {}
	public function play():Void {}
	public function stop():Void {}
	public function restart():Void {}
	public function update(elapsed:Float):Void {}
	public function pause():Void {}
	public function resume():Void {}
	public function togglePause():Void {}
	public function clearPause():Void {}
	public function onStop():Void { stopped = true; }
	public function onRestart():Void { restarted = true; }
	public function onPlay():Void { played = true; }
	public function onEnd():Void { ended = true; }
	public function alpha():Void {}
	public function unalpha():Void {}
	public function hide():Void { visible = false; }
	public function show():Void { visible = true; }
	#end
}
