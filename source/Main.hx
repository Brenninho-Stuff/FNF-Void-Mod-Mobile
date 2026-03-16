package;

import lime.app.Application;
#if windows
import Discord.DiscordClient;
#end
#if android
import android.Tools as AndroidTools;
#end
import openfl.display.BlendMode;
import openfl.text.TextFormat;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.system.System;

class Main extends Sprite
{
    var gameWidth:Int = 1280; 
    var gameHeight:Int = 720; 
    var initialState:Class<FlxState> = TitleState; 
    var zoom:Float = -1; 
    var framerate:Int = 60;
    var skipSplash:Bool = true; 
    var startFullscreen:Bool = true; 

    public static var watermarks = true; 

    public static function main():Void
    {
        Lib.current.addChild(new Main());
    }

    public function new()
    {
        super();

        if (stage != null)
        {
            init();
        }
        else
        {
            addEventListener(Event.ADDED_TO_STAGE, init);
        }
    }

    private function init(?E:Event):Void
    {
        if (hasEventListener(Event.ADDED_TO_STAGE))
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
        }

        setupGame();
    }

    private function setupGame():Void
    {
        var stageWidth:Int = Lib.current.stage.stageWidth;
        var stageHeight:Int = Lib.current.stage.stageHeight;

        if (zoom == -1)
        {
            var ratioX:Float = stageWidth / gameWidth;
            var ratioY:Float = stageHeight / gameHeight;
            zoom = Math.min(ratioX, ratioY);
            gameWidth = Math.ceil(stageWidth / zoom);
            gameHeight = Math.ceil(stageHeight / zoom);
        }

        #if cpp
        initialState = Caching;
        #end

        game = new FlxGame(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen);

        addChild(game);

        fpsCounter = new FPS(10, 10, 0xFFFFFF);
        addChild(fpsCounter);

        if (FlxG.save.data.fps != null) {
            toggleFPS(FlxG.save.data.fps);
        }

        #if windows
        DiscordClient.initialize();
        #end

        Application.current.onExit.add(function(exitCode) {
            #if windows
            DiscordClient.shutdown();
            #end
            System.gc();
        });
    }

    var game:FlxGame;
    var fpsCounter:FPS;

    public function toggleFPS(fpsEnabled:Bool):Void {
        if (fpsCounter != null)
            fpsCounter.visible = fpsEnabled;
    }

    public function changeFPSColor(color:FlxColor)
    {
        fpsCounter.textColor = color;
    }

    public function setFPSCap(cap:Float)
    {
        openfl.Lib.current.stage.frameRate = cap;
    }

    public function getFPSCap():Float
    {
        return openfl.Lib.current.stage.frameRate;
    }

    public function getFPS():Float
    {
        return fpsCounter.currentFPS;
    }
}