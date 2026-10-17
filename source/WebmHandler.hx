package;

import flixel.FlxG;
import openfl.display.Sprite;
#if !web
import hxvlc.flixel.FlxVideoSprite;
#end

/**
 * hxvlc 视频适配层（替代原 webm extension 实现）
 * - 桌面端 / 移动端统一使用 hxvlc.flixel.FlxVideoSprite 播放（VLC 内核，支持 webm/mp4）
 * - FlxVideoSprite extends FlxSprite，走 flixel 渲染管线，可直接 add 进状态树，
 *   坐标/缩放/居中与游戏 UI 完全一致，不会像 FlxVideo 那样出现偏移或大小问题
 * - web 端保留占位（web 目标继续走 VideoHandler/NetStream）
 */
class WebmHandler
{
	#if !web
	public var video:FlxVideoSprite;
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

	/** 创建 hxvlc 播放器；若上一轮 VideoState 销毁时把 FlxVideoSprite 一起 destroy 了（bitmap 被清空），这里自动重建 */
	public function makePlayer():Void
	{
		if (initialized && video != null && video.bitmap != null) return;

		video = new FlxVideoSprite();
		// FlxVideoSprite 的事件/音量挂在 bitmap（内部 FlxVideo）上
		video.bitmap.onEndReached.add(function()
		{
			onEnd();
		});
		video.visible = false;

		initialized = true;
	}

	/** 加载 / 切换视频源 */
	public function updatePlayer():Void
	{
		if (!initialized || video == null || video.bitmap == null) makePlayer();
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
		if (!initialized || video == null || video.bitmap == null) return;

		// FlxVideoSprite 走 flixel 逻辑坐标，直接用 FlxG.width/height 做 letterbox 居中
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

		video.setGraphicSize(Std.int(appliedWidth), Std.int(appliedHeight));
		video.updateHitbox();
		video.x = remainingX;
		video.y = remainingY;
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
