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

		video.x = GlobalVideo.calc(0);
		video.y = GlobalVideo.calc(1);
		video.width = GlobalVideo.calc(2);
		video.height = GlobalVideo.calc(3);
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
