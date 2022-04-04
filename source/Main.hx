package;

import helpers.Achievements;
import helpers.Global;
import flixel.util.FlxSave;
import states.SplashScreenState;
import misc.Macros;
import states.MainMenuState;
import flixel.FlxState;
import config.Configure;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.util.FlxColor;
import misc.FlxTextFactory;
import openfl.display.Sprite;
#if play
import states.PlayState;
#elseif jake
import states.dev.JakesPlayState;
#elseif logan
import states.dev.LogansPlayState;
#elseif mike
import states.dev.MikesPlayState;
#elseif soft
import states.dev.SoftBodyState;
#elseif shapes
import states.dev.AllShapesState;
#elseif settings
import states.SettingsState;
#elseif achievements
import states.AchievementsState;
#end

class Main extends Sprite {
	public function new() {
		super();
		Configure.initAnalytics(false);

		loadData();
		Achievements.initAchievements();

		var startingState:Class<FlxState> = SplashScreenState;
		#if play
		startingState = PlayState;
		#elseif jake
		startingState = JakesPlayState;
		#elseif logan
		startingState = LogansPlayState;
		#elseif mike
		startingState = MikesPlayState;
		#elseif shapes
		startingState = AllShapesState;
		#elseif soft
		startingState = SoftBodyState;
		#elseif settings
		startingState = SettingsState;
		#elseif achievements
		startingState = AchievementsState;
		#else
		if (Macros.isDefined("SKIP_SPLASH")) {
			startingState = MainMenuState;
		}
		#end
		addChild(new FlxGame(0, 0, startingState, 1, 60, 60, true, false));

		FlxG.fixedTimestep = false;

		// Disable flixel volume controls as we don't use them because of FMOD
		FlxG.sound.muteKeys = null;
		FlxG.sound.volumeUpKeys = null;
		FlxG.sound.volumeDownKeys = null;

		// Don't use the flixel cursor
		FlxG.mouse.useSystemCursor = true;

		#if debug
		FlxG.autoPause = false;
		#end

		// Set up basic transitions. To override these see `transOut` and `transIn` on any FlxTransitionable states
		FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 0.35);
		FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.35);

		FlxTextFactory.defaultFont = AssetPaths.Brain_Slab_8__ttf;
	}
}
