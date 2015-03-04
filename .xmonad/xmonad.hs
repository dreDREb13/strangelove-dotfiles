import	XMonad
import	XMonad.Actions.CycleWS
import	XMonad.Actions.FloatKeys
import	XMonad.Layout.Spacing
import	XMonad.Layout.NoBorders
import	XMonad.Layout.PerWorkspace
import	XMonad.Layout.Accordion
import	XMonad.Hooks.DynamicLog
import	XMonad.Hooks.ManageDocks
import	XMonad.Util.Run(spawnPipe)
import	XMonad.Util.EZConfig(additionalKeys)
import	Graphics.X11.ExtraTypes.XF86
import	System.IO

--	Define amount and names of workspaces
myWorkspaces	=
	[
		"1:main","2:net","3:music","4:work","5:writing","6:media"
	]

--	Define whether XMonad will shift applications to different workspaces
myManageHook	=	composeAll
	[
		className	=?	"Pale moon"	-->	doShift	"2:net",
		className	=?	"geany"		-->	doShift "4:work",
		className	=?	"vlc"		-->	doShift	"6:media",
		className	=?	"libreoffice"	-->	doShift	"5:writing",
		className	=?	"gimp"		-->	doFloat,
		className	=?	"gcolor2"	-->	doFloat,
		className	=?	"viewnior"	-->	doFloat
	]

--	Set custom layout
defaultLayouts	=	tiled ||| Mirror tiled ||| Accordion ||| Full
	where
		-- Default tiling algorithm partitions the screen into two panes
		tiled	=	spacing 3 $ Tall nmaster delta ratio
		
		-- The default number of windows in the master pane
		nmaster	=	1
		
		-- Default proportion of screen occupied by the master pane
		ratio	=	2/3
		
		-- Percent of screen to increment by when resizing panes
		delta	=	5/100
		
--	Set "2:net" workspace to default as Full
workspaceNet	=	Full

--	Apply changes to myLayout
myLayout		=	onWorkspace "2:net" workspaceNet $ defaultLayouts

--	Begin XMonad
main	=	do
	xmproc	<-	spawnPipe "xmobar"
	xmonad $ defaultConfig
		{
			workspaces					=	myWorkspaces,						--	set the workspaces to my configured variable
			manageHook					=	manageDocks	<+>	myManageHook					
												<+>	manageHook defaultConfig,
			layoutHook					=	avoidStruts $ myLayout,					--	set tiling to my configured variable while avoiding XMobar
			logHook						=	dynamicLogWithPP $ xmobarPP
				{
					ppOutput			=	hPutStrLn xmproc,					--	Print current window string contents
					ppTitle				=	xmobarColor	"#F6BB97" "" . shorten 30,		--	Set current window font color
					ppHiddenNoWindows		=	xmobarColor	"#A7BCBF" "",				--	Set workspaces to always display with inactive color
					ppHidden			=	xmobarColor	"#CDDEA6" "",				--	Set workspaces with open windows to display running window color
					ppCurrent			=	xmobarColor	"#F3F792" "",				--	Set current workspace to active color
					ppSep				=	" \\ ",							--	Set divider between window type
					ppWsSep				=	" # ",							--	Set dividers between workspaces
					ppLayout			=	(\x -> case x of					--	Change workspace layout display
												"Spacing 3 Tall"	->	"^{}"	--	Tall changes to ^{}
												"Mirror Spacing 3 Tall"	->	"x{}"	--	Mirror Tall changes to x{}
												"Accordion"		->	"{|}"	--	Accordion changes to {|} 
												"Full"			->	"{ }"	--	Full changes to {}
												_			->	x	--	Null
											)
				},
			terminal					=	"terminator",						--	Make Terminator default terminal
			modMask						=	mod4Mask,						--	Rebind Mod to Windows key
			borderWidth					=	2,							--	Set borders to 2px wide
			normalBorderColor				=	"#907060",						--	Set border color when not in use
			focusedBorderColor				=	"#E0B39B"						--	Set border color when in use
		} `additionalKeys`
		[
			((mod4Mask .|. shiftMask, xK_z),		spawn "xscreensaver-command -lock"),				--	Set screensaver and lock screen
			((controlMask, xK_Print), 			spawn "sleep 0.2; scrot -s"),					--	Take screenshot after a delay
			((0, xK_Print),					spawn "scrot"),							--	Take screenshot
			((mod4Mask .|. shiftMask, xK_q),		spawn "shutdown -h now"), 					-- 	Shutdown computer
			((mod4Mask, xK_q),				kill),												--	Kills applications
			((mod4Mask,	xK_minus),			withFocused (keysResizeWindow (-20,-20) (0,0))),		--	Resize window by -20 pixels	
			((mod4Mask,	xK_equal),			withFocused (keysResizeWindow (20,20) (0,0))),			--	Resize window by +20 pixels
			((mod4Mask .|. shiftMask, xK_equal),		withFocused	(keysResizeWindow (0,20) (0,0))),		--	Resize window by +20 pixels down
			((mod4Mask .|. shiftMask, xK_minus),		withFocused	(keysResizeWindow (0,-20) (0,0))),		--	Resize window by -20 pixels up
			((mod4Mask,	xK_Left),			withFocused (keysMoveWindow (-10,0))),				--	Move window 10 pixels left
			((mod4Mask .|. shiftMask, xK_Left),		withFocused (keysMoveWindow (-50,0))),				--	Move window 50 pixels left
			((mod4Mask,	xK_Right),			withFocused (keysMoveWindow (10,0))),				--	Move window 10 pixels right
			((mod4Mask .|. shiftMask, xK_Right),		withFocused (keysMoveWindow (50,0))),				--	Move window 50 pixels right
			((mod4Mask,	xK_Up),				withFocused (keysMoveWindow (0,-10))),				--	Move window 10 pixels up
			((mod4Mask .|. shiftMask, xK_Up),		withFocused (keysMoveWindow (0,-50))),				--	Move window 50 pixels up
			((mod4Mask,	xK_Down),			withFocused (keysMoveWindow (0,10))),				--	Move window 10 pixels down
			((mod4Mask .|. shiftMask, xK_Down),		withFocused	(keysMoveWindow (0,50))),			--	Move window 50 pixels down
			((mod4Mask,	xK_f),				spawn "thunar"),						--	Starts file manager
			((mod4Mask, xK_b),				spawn "palemoon"),						--	Starts net browser
			((mod4Mask, xK_e),				spawn "geany"), 						--	Starts text editor
			((mod4Mask, xK_d),				spawn "deluge"),						--	Starts bittorent client
			((mod4Mask, xK_t),				spawn "terminator"),						--	Starts terminal
			((mod4Mask .|. shiftMask, xK_Return),		return()),							--	Disable default terminal function
			((mod4Mask,	xK_bracketright),		nextWS),							--	Move to next workspace (left)
			((mod4Mask .|. shiftMask, xK_bracketright),	shiftToNext),							--	Move window to next workspace (left)
			((mod4Mask,	xK_bracketleft),		prevWS),							--	Move to previous workspace (right)
			((mod4Mask .|. shiftMask, xK_bracketleft),	shiftToPrev),							--	Move window to previous workspace (right)
			((0, xF86XK_MonBrightnessUp),			spawn "xbacklight +10"),					--	Set brightness +10
			((0, xF86XK_MonBrightnessDown),			spawn "xbacklight -10"),					--	Set brightness -10
			((0, xF86XK_AudioPrev),				spawn "mpc prev"),						--	Skip to previous song - ncmpcpp
			((0, xF86XK_AudioNext),				spawn "mpc next"),						--	Skip to next song - ncmpcpp
			((0, xF86XK_AudioPlay),				spawn "mpc toggle"),						--	Play / Pause song - ncmpcpp
			((0, xF86XK_AudioMute),				spawn "amixer -q sset Master toggle"),				--	Mute audio
			((0, xF86XK_AudioLowerVolume),			spawn "amixer -q sset Master 2%-"),				--	Set audio -2%
			((0, xF86XK_AudioRaiseVolume),			spawn "amixer -q sset Master 2%+")				--	Set audio +2%
		]
