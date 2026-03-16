package;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.system.FlxAssets.FlxGraphicAsset;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;

class Paths
{
	inline public static var SOUND_EXT = #if (web || ios) "mp3" #else "ogg" #end;

	static var currentLevel:String;

	// Nomes de músicas que diferem do padrão nome-com-hifen
	static final SONG_NAME_FIXES:Map<String, String> = [
		'dad-battle' => 'dadbattle',
		'philly-nice' => 'philly'
	];

	static public function setCurrentLevel(name:String):Void
	{
		currentLevel = name.toLowerCase();
	}

	static function getPath(file:String, type:AssetType, library:Null<String>):String
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath = getLibraryPathForce(file, currentLevel);
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload"):String
	{
		return (library == "preload" || library == "default") ? getPreloadPath(file) : getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String):String
	{
		return '$library:assets/$library/$file';
	}

	inline static function getPreloadPath(file:String):String
	{
		return 'assets/$file';
	}

	// Normaliza nome da música: espaços viram hífens, lowercase, e aplica fixes
	static function normalizeSongName(song:String):String
	{
		var key = StringTools.replace(song, " ", "-").toLowerCase();
		return SONG_NAME_FIXES.exists(key) ? SONG_NAME_FIXES.get(key) : key;
	}

	inline static public function file(file:String, ?library:String, type:AssetType = TEXT):String
	{
		return getPath(file, type, library);
	}

	inline static public function lua(key:String, ?library:String):String
	{
		return getPath('data/$key.lua', TEXT, library);
	}

	inline static public function luaImage(key:String, ?library:String):String
	{
		return getPath('data/$key.png', IMAGE, library);
	}

	inline static public function txt(key:String, ?library:String):String
	{
		return getPath('$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String):String
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String):String
	{
		return getPath('data/$key.json', TEXT, library);
	}

	inline static public function sound(key:String, ?library:String):String
	{
		return getPath('sounds/$key.$SOUND_EXT', SOUND, library);
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String):String
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String):String
	{
		return getPath('music/$key.$SOUND_EXT', MUSIC, library);
	}

	inline static public function voices(song:String):String
	{
		return 'songs:assets/songs/${normalizeSongName(song)}/Voices.$SOUND_EXT';
	}

	inline static public function inst(song:String):String
	{
		return 'songs:assets/songs/${normalizeSongName(song)}/Inst.$SOUND_EXT';
	}

	inline static public function image(key:String, ?library:String):String
	{
		return getPath('images/$key.png', IMAGE, library);
	}

	inline static public function font(key:String):String
	{
		return 'assets/fonts/$key';
	}

	// Retorna true se o cache de imagens está ativo (apenas em cpp/android/ios)
	static function useImageCache():Bool
	{
		#if (cpp || android || ios)
		return FlxG.save.data.cacheImages == true;
		#else
		return false;
		#end
	}

	#if (cpp || android || ios)
	inline static public function imageCached(key:String):FlxGraphic
	{
		return Caching.bitmapData.get(key);
	}
	#end

	static public function getSparrowAtlas(key:String, ?library:String, ?isCharacter:Bool = false):FlxAtlasFrames
	{
		if (isCharacter)
		{
			#if (cpp || android || ios)
			if (useImageCache())
				return FlxAtlasFrames.fromSparrow(imageCached(key), file('images/characters/$key.xml', library));
			#end
			return FlxAtlasFrames.fromSparrow(image('characters/$key', library), file('images/characters/$key.xml', library));
		}

		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
	}

	static public function getPackerAtlas(key:String, ?library:String, ?isCharacter:Bool = false):FlxAtlasFrames
	{
		if (isCharacter)
		{
			#if (cpp || android || ios)
			if (useImageCache())
				return FlxAtlasFrames.fromSpriteSheetPacker(imageCached(key), file('images/characters/$key.txt', library));
			#end
			return FlxAtlasFrames.fromSpriteSheetPacker(image('characters/$key', library), file('images/characters/$key.txt', library));
		}

		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
	}
}