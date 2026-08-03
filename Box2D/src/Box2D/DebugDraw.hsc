{-# LANGUAGE ForeignFunctionInterface #-}
{-# LANGUAGE PatternSynonyms #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

-- Produced by boxnd-gen; edit the generator, not this file.

module Box2D.DebugDraw
  ( HexColor (..)
  , pattern ColorAliceBlue
  , pattern ColorAntiqueWhite
  , pattern ColorAqua
  , pattern ColorAquamarine
  , pattern ColorAzure
  , pattern ColorBeige
  , pattern ColorBisque
  , pattern ColorBlack
  , pattern ColorBlanchedAlmond
  , pattern ColorBlue
  , pattern ColorBlueViolet
  , pattern ColorBrown
  , pattern ColorBurlywood
  , pattern ColorCadetBlue
  , pattern ColorChartreuse
  , pattern ColorChocolate
  , pattern ColorCoral
  , pattern ColorCornflowerBlue
  , pattern ColorCornsilk
  , pattern ColorCrimson
  , pattern ColorCyan
  , pattern ColorDarkBlue
  , pattern ColorDarkCyan
  , pattern ColorDarkGoldenRod
  , pattern ColorDarkGray
  , pattern ColorDarkGreen
  , pattern ColorDarkKhaki
  , pattern ColorDarkMagenta
  , pattern ColorDarkOliveGreen
  , pattern ColorDarkOrange
  , pattern ColorDarkOrchid
  , pattern ColorDarkRed
  , pattern ColorDarkSalmon
  , pattern ColorDarkSeaGreen
  , pattern ColorDarkSlateBlue
  , pattern ColorDarkSlateGray
  , pattern ColorDarkTurquoise
  , pattern ColorDarkViolet
  , pattern ColorDeepPink
  , pattern ColorDeepSkyBlue
  , pattern ColorDimGray
  , pattern ColorDodgerBlue
  , pattern ColorFireBrick
  , pattern ColorFloralWhite
  , pattern ColorForestGreen
  , pattern ColorFuchsia
  , pattern ColorGainsboro
  , pattern ColorGhostWhite
  , pattern ColorGold
  , pattern ColorGoldenRod
  , pattern ColorGray
  , pattern ColorGreen
  , pattern ColorGreenYellow
  , pattern ColorHoneyDew
  , pattern ColorHotPink
  , pattern ColorIndianRed
  , pattern ColorIndigo
  , pattern ColorIvory
  , pattern ColorKhaki
  , pattern ColorLavender
  , pattern ColorLavenderBlush
  , pattern ColorLawnGreen
  , pattern ColorLemonChiffon
  , pattern ColorLightBlue
  , pattern ColorLightCoral
  , pattern ColorLightCyan
  , pattern ColorLightGoldenRodYellow
  , pattern ColorLightGray
  , pattern ColorLightGreen
  , pattern ColorLightPink
  , pattern ColorLightSalmon
  , pattern ColorLightSeaGreen
  , pattern ColorLightSkyBlue
  , pattern ColorLightSlateGray
  , pattern ColorLightSteelBlue
  , pattern ColorLightYellow
  , pattern ColorLime
  , pattern ColorLimeGreen
  , pattern ColorLinen
  , pattern ColorMagenta
  , pattern ColorMaroon
  , pattern ColorMediumAquaMarine
  , pattern ColorMediumBlue
  , pattern ColorMediumOrchid
  , pattern ColorMediumPurple
  , pattern ColorMediumSeaGreen
  , pattern ColorMediumSlateBlue
  , pattern ColorMediumSpringGreen
  , pattern ColorMediumTurquoise
  , pattern ColorMediumVioletRed
  , pattern ColorMidnightBlue
  , pattern ColorMintCream
  , pattern ColorMistyRose
  , pattern ColorMoccasin
  , pattern ColorNavajoWhite
  , pattern ColorNavy
  , pattern ColorOldLace
  , pattern ColorOlive
  , pattern ColorOliveDrab
  , pattern ColorOrange
  , pattern ColorOrangeRed
  , pattern ColorOrchid
  , pattern ColorPaleGoldenRod
  , pattern ColorPaleGreen
  , pattern ColorPaleTurquoise
  , pattern ColorPaleVioletRed
  , pattern ColorPapayaWhip
  , pattern ColorPeachPuff
  , pattern ColorPeru
  , pattern ColorPink
  , pattern ColorPlum
  , pattern ColorPowderBlue
  , pattern ColorPurple
  , pattern ColorRebeccaPurple
  , pattern ColorRed
  , pattern ColorRosyBrown
  , pattern ColorRoyalBlue
  , pattern ColorSaddleBrown
  , pattern ColorSalmon
  , pattern ColorSandyBrown
  , pattern ColorSeaGreen
  , pattern ColorSeaShell
  , pattern ColorSienna
  , pattern ColorSilver
  , pattern ColorSkyBlue
  , pattern ColorSlateBlue
  , pattern ColorSlateGray
  , pattern ColorSnow
  , pattern ColorSpringGreen
  , pattern ColorSteelBlue
  , pattern ColorTan
  , pattern ColorTeal
  , pattern ColorThistle
  , pattern ColorTomato
  , pattern ColorTurquoise
  , pattern ColorViolet
  , pattern ColorWheat
  , pattern ColorWhite
  , pattern ColorWhiteSmoke
  , pattern ColorYellow
  , pattern ColorYellowGreen
  , pattern ColorBox2DRed
  , pattern ColorBox2DBlue
  , pattern ColorBox2DGreen
  , pattern ColorBox2DYellow
  )
  where

import Foreign
import Foreign.C.Types (CInt (..))

#include "box2d/box2d.h"


-- | These colors are used for debug draw and mostly match the named SVG colors.
newtype HexColor = HexColor CInt
  deriving (Eq, Show, Storable)

pattern ColorAliceBlue :: HexColor
pattern ColorAntiqueWhite :: HexColor
pattern ColorAqua :: HexColor
pattern ColorAquamarine :: HexColor
pattern ColorAzure :: HexColor
pattern ColorBeige :: HexColor
pattern ColorBisque :: HexColor
pattern ColorBlack :: HexColor
pattern ColorBlanchedAlmond :: HexColor
pattern ColorBlue :: HexColor
pattern ColorBlueViolet :: HexColor
pattern ColorBrown :: HexColor
pattern ColorBurlywood :: HexColor
pattern ColorCadetBlue :: HexColor
pattern ColorChartreuse :: HexColor
pattern ColorChocolate :: HexColor
pattern ColorCoral :: HexColor
pattern ColorCornflowerBlue :: HexColor
pattern ColorCornsilk :: HexColor
pattern ColorCrimson :: HexColor
pattern ColorCyan :: HexColor
pattern ColorDarkBlue :: HexColor
pattern ColorDarkCyan :: HexColor
pattern ColorDarkGoldenRod :: HexColor
pattern ColorDarkGray :: HexColor
pattern ColorDarkGreen :: HexColor
pattern ColorDarkKhaki :: HexColor
pattern ColorDarkMagenta :: HexColor
pattern ColorDarkOliveGreen :: HexColor
pattern ColorDarkOrange :: HexColor
pattern ColorDarkOrchid :: HexColor
pattern ColorDarkRed :: HexColor
pattern ColorDarkSalmon :: HexColor
pattern ColorDarkSeaGreen :: HexColor
pattern ColorDarkSlateBlue :: HexColor
pattern ColorDarkSlateGray :: HexColor
pattern ColorDarkTurquoise :: HexColor
pattern ColorDarkViolet :: HexColor
pattern ColorDeepPink :: HexColor
pattern ColorDeepSkyBlue :: HexColor
pattern ColorDimGray :: HexColor
pattern ColorDodgerBlue :: HexColor
pattern ColorFireBrick :: HexColor
pattern ColorFloralWhite :: HexColor
pattern ColorForestGreen :: HexColor
pattern ColorFuchsia :: HexColor
pattern ColorGainsboro :: HexColor
pattern ColorGhostWhite :: HexColor
pattern ColorGold :: HexColor
pattern ColorGoldenRod :: HexColor
pattern ColorGray :: HexColor
pattern ColorGreen :: HexColor
pattern ColorGreenYellow :: HexColor
pattern ColorHoneyDew :: HexColor
pattern ColorHotPink :: HexColor
pattern ColorIndianRed :: HexColor
pattern ColorIndigo :: HexColor
pattern ColorIvory :: HexColor
pattern ColorKhaki :: HexColor
pattern ColorLavender :: HexColor
pattern ColorLavenderBlush :: HexColor
pattern ColorLawnGreen :: HexColor
pattern ColorLemonChiffon :: HexColor
pattern ColorLightBlue :: HexColor
pattern ColorLightCoral :: HexColor
pattern ColorLightCyan :: HexColor
pattern ColorLightGoldenRodYellow :: HexColor
pattern ColorLightGray :: HexColor
pattern ColorLightGreen :: HexColor
pattern ColorLightPink :: HexColor
pattern ColorLightSalmon :: HexColor
pattern ColorLightSeaGreen :: HexColor
pattern ColorLightSkyBlue :: HexColor
pattern ColorLightSlateGray :: HexColor
pattern ColorLightSteelBlue :: HexColor
pattern ColorLightYellow :: HexColor
pattern ColorLime :: HexColor
pattern ColorLimeGreen :: HexColor
pattern ColorLinen :: HexColor
pattern ColorMagenta :: HexColor
pattern ColorMaroon :: HexColor
pattern ColorMediumAquaMarine :: HexColor
pattern ColorMediumBlue :: HexColor
pattern ColorMediumOrchid :: HexColor
pattern ColorMediumPurple :: HexColor
pattern ColorMediumSeaGreen :: HexColor
pattern ColorMediumSlateBlue :: HexColor
pattern ColorMediumSpringGreen :: HexColor
pattern ColorMediumTurquoise :: HexColor
pattern ColorMediumVioletRed :: HexColor
pattern ColorMidnightBlue :: HexColor
pattern ColorMintCream :: HexColor
pattern ColorMistyRose :: HexColor
pattern ColorMoccasin :: HexColor
pattern ColorNavajoWhite :: HexColor
pattern ColorNavy :: HexColor
pattern ColorOldLace :: HexColor
pattern ColorOlive :: HexColor
pattern ColorOliveDrab :: HexColor
pattern ColorOrange :: HexColor
pattern ColorOrangeRed :: HexColor
pattern ColorOrchid :: HexColor
pattern ColorPaleGoldenRod :: HexColor
pattern ColorPaleGreen :: HexColor
pattern ColorPaleTurquoise :: HexColor
pattern ColorPaleVioletRed :: HexColor
pattern ColorPapayaWhip :: HexColor
pattern ColorPeachPuff :: HexColor
pattern ColorPeru :: HexColor
pattern ColorPink :: HexColor
pattern ColorPlum :: HexColor
pattern ColorPowderBlue :: HexColor
pattern ColorPurple :: HexColor
pattern ColorRebeccaPurple :: HexColor
pattern ColorRed :: HexColor
pattern ColorRosyBrown :: HexColor
pattern ColorRoyalBlue :: HexColor
pattern ColorSaddleBrown :: HexColor
pattern ColorSalmon :: HexColor
pattern ColorSandyBrown :: HexColor
pattern ColorSeaGreen :: HexColor
pattern ColorSeaShell :: HexColor
pattern ColorSienna :: HexColor
pattern ColorSilver :: HexColor
pattern ColorSkyBlue :: HexColor
pattern ColorSlateBlue :: HexColor
pattern ColorSlateGray :: HexColor
pattern ColorSnow :: HexColor
pattern ColorSpringGreen :: HexColor
pattern ColorSteelBlue :: HexColor
pattern ColorTan :: HexColor
pattern ColorTeal :: HexColor
pattern ColorThistle :: HexColor
pattern ColorTomato :: HexColor
pattern ColorTurquoise :: HexColor
pattern ColorViolet :: HexColor
pattern ColorWheat :: HexColor
pattern ColorWhite :: HexColor
pattern ColorWhiteSmoke :: HexColor
pattern ColorYellow :: HexColor
pattern ColorYellowGreen :: HexColor
pattern ColorBox2DRed :: HexColor
pattern ColorBox2DBlue :: HexColor
pattern ColorBox2DGreen :: HexColor
pattern ColorBox2DYellow :: HexColor
pattern ColorAliceBlue = HexColor #{const b2_colorAliceBlue}
pattern ColorAntiqueWhite = HexColor #{const b2_colorAntiqueWhite}
pattern ColorAqua = HexColor #{const b2_colorAqua}
pattern ColorAquamarine = HexColor #{const b2_colorAquamarine}
pattern ColorAzure = HexColor #{const b2_colorAzure}
pattern ColorBeige = HexColor #{const b2_colorBeige}
pattern ColorBisque = HexColor #{const b2_colorBisque}
pattern ColorBlack = HexColor #{const b2_colorBlack}
pattern ColorBlanchedAlmond = HexColor #{const b2_colorBlanchedAlmond}
pattern ColorBlue = HexColor #{const b2_colorBlue}
pattern ColorBlueViolet = HexColor #{const b2_colorBlueViolet}
pattern ColorBrown = HexColor #{const b2_colorBrown}
pattern ColorBurlywood = HexColor #{const b2_colorBurlywood}
pattern ColorCadetBlue = HexColor #{const b2_colorCadetBlue}
pattern ColorChartreuse = HexColor #{const b2_colorChartreuse}
pattern ColorChocolate = HexColor #{const b2_colorChocolate}
pattern ColorCoral = HexColor #{const b2_colorCoral}
pattern ColorCornflowerBlue = HexColor #{const b2_colorCornflowerBlue}
pattern ColorCornsilk = HexColor #{const b2_colorCornsilk}
pattern ColorCrimson = HexColor #{const b2_colorCrimson}
pattern ColorCyan = HexColor #{const b2_colorCyan}
pattern ColorDarkBlue = HexColor #{const b2_colorDarkBlue}
pattern ColorDarkCyan = HexColor #{const b2_colorDarkCyan}
pattern ColorDarkGoldenRod = HexColor #{const b2_colorDarkGoldenRod}
pattern ColorDarkGray = HexColor #{const b2_colorDarkGray}
pattern ColorDarkGreen = HexColor #{const b2_colorDarkGreen}
pattern ColorDarkKhaki = HexColor #{const b2_colorDarkKhaki}
pattern ColorDarkMagenta = HexColor #{const b2_colorDarkMagenta}
pattern ColorDarkOliveGreen = HexColor #{const b2_colorDarkOliveGreen}
pattern ColorDarkOrange = HexColor #{const b2_colorDarkOrange}
pattern ColorDarkOrchid = HexColor #{const b2_colorDarkOrchid}
pattern ColorDarkRed = HexColor #{const b2_colorDarkRed}
pattern ColorDarkSalmon = HexColor #{const b2_colorDarkSalmon}
pattern ColorDarkSeaGreen = HexColor #{const b2_colorDarkSeaGreen}
pattern ColorDarkSlateBlue = HexColor #{const b2_colorDarkSlateBlue}
pattern ColorDarkSlateGray = HexColor #{const b2_colorDarkSlateGray}
pattern ColorDarkTurquoise = HexColor #{const b2_colorDarkTurquoise}
pattern ColorDarkViolet = HexColor #{const b2_colorDarkViolet}
pattern ColorDeepPink = HexColor #{const b2_colorDeepPink}
pattern ColorDeepSkyBlue = HexColor #{const b2_colorDeepSkyBlue}
pattern ColorDimGray = HexColor #{const b2_colorDimGray}
pattern ColorDodgerBlue = HexColor #{const b2_colorDodgerBlue}
pattern ColorFireBrick = HexColor #{const b2_colorFireBrick}
pattern ColorFloralWhite = HexColor #{const b2_colorFloralWhite}
pattern ColorForestGreen = HexColor #{const b2_colorForestGreen}
pattern ColorFuchsia = HexColor #{const b2_colorFuchsia}
pattern ColorGainsboro = HexColor #{const b2_colorGainsboro}
pattern ColorGhostWhite = HexColor #{const b2_colorGhostWhite}
pattern ColorGold = HexColor #{const b2_colorGold}
pattern ColorGoldenRod = HexColor #{const b2_colorGoldenRod}
pattern ColorGray = HexColor #{const b2_colorGray}
pattern ColorGreen = HexColor #{const b2_colorGreen}
pattern ColorGreenYellow = HexColor #{const b2_colorGreenYellow}
pattern ColorHoneyDew = HexColor #{const b2_colorHoneyDew}
pattern ColorHotPink = HexColor #{const b2_colorHotPink}
pattern ColorIndianRed = HexColor #{const b2_colorIndianRed}
pattern ColorIndigo = HexColor #{const b2_colorIndigo}
pattern ColorIvory = HexColor #{const b2_colorIvory}
pattern ColorKhaki = HexColor #{const b2_colorKhaki}
pattern ColorLavender = HexColor #{const b2_colorLavender}
pattern ColorLavenderBlush = HexColor #{const b2_colorLavenderBlush}
pattern ColorLawnGreen = HexColor #{const b2_colorLawnGreen}
pattern ColorLemonChiffon = HexColor #{const b2_colorLemonChiffon}
pattern ColorLightBlue = HexColor #{const b2_colorLightBlue}
pattern ColorLightCoral = HexColor #{const b2_colorLightCoral}
pattern ColorLightCyan = HexColor #{const b2_colorLightCyan}
pattern ColorLightGoldenRodYellow = HexColor #{const b2_colorLightGoldenRodYellow}
pattern ColorLightGray = HexColor #{const b2_colorLightGray}
pattern ColorLightGreen = HexColor #{const b2_colorLightGreen}
pattern ColorLightPink = HexColor #{const b2_colorLightPink}
pattern ColorLightSalmon = HexColor #{const b2_colorLightSalmon}
pattern ColorLightSeaGreen = HexColor #{const b2_colorLightSeaGreen}
pattern ColorLightSkyBlue = HexColor #{const b2_colorLightSkyBlue}
pattern ColorLightSlateGray = HexColor #{const b2_colorLightSlateGray}
pattern ColorLightSteelBlue = HexColor #{const b2_colorLightSteelBlue}
pattern ColorLightYellow = HexColor #{const b2_colorLightYellow}
pattern ColorLime = HexColor #{const b2_colorLime}
pattern ColorLimeGreen = HexColor #{const b2_colorLimeGreen}
pattern ColorLinen = HexColor #{const b2_colorLinen}
pattern ColorMagenta = HexColor #{const b2_colorMagenta}
pattern ColorMaroon = HexColor #{const b2_colorMaroon}
pattern ColorMediumAquaMarine = HexColor #{const b2_colorMediumAquaMarine}
pattern ColorMediumBlue = HexColor #{const b2_colorMediumBlue}
pattern ColorMediumOrchid = HexColor #{const b2_colorMediumOrchid}
pattern ColorMediumPurple = HexColor #{const b2_colorMediumPurple}
pattern ColorMediumSeaGreen = HexColor #{const b2_colorMediumSeaGreen}
pattern ColorMediumSlateBlue = HexColor #{const b2_colorMediumSlateBlue}
pattern ColorMediumSpringGreen = HexColor #{const b2_colorMediumSpringGreen}
pattern ColorMediumTurquoise = HexColor #{const b2_colorMediumTurquoise}
pattern ColorMediumVioletRed = HexColor #{const b2_colorMediumVioletRed}
pattern ColorMidnightBlue = HexColor #{const b2_colorMidnightBlue}
pattern ColorMintCream = HexColor #{const b2_colorMintCream}
pattern ColorMistyRose = HexColor #{const b2_colorMistyRose}
pattern ColorMoccasin = HexColor #{const b2_colorMoccasin}
pattern ColorNavajoWhite = HexColor #{const b2_colorNavajoWhite}
pattern ColorNavy = HexColor #{const b2_colorNavy}
pattern ColorOldLace = HexColor #{const b2_colorOldLace}
pattern ColorOlive = HexColor #{const b2_colorOlive}
pattern ColorOliveDrab = HexColor #{const b2_colorOliveDrab}
pattern ColorOrange = HexColor #{const b2_colorOrange}
pattern ColorOrangeRed = HexColor #{const b2_colorOrangeRed}
pattern ColorOrchid = HexColor #{const b2_colorOrchid}
pattern ColorPaleGoldenRod = HexColor #{const b2_colorPaleGoldenRod}
pattern ColorPaleGreen = HexColor #{const b2_colorPaleGreen}
pattern ColorPaleTurquoise = HexColor #{const b2_colorPaleTurquoise}
pattern ColorPaleVioletRed = HexColor #{const b2_colorPaleVioletRed}
pattern ColorPapayaWhip = HexColor #{const b2_colorPapayaWhip}
pattern ColorPeachPuff = HexColor #{const b2_colorPeachPuff}
pattern ColorPeru = HexColor #{const b2_colorPeru}
pattern ColorPink = HexColor #{const b2_colorPink}
pattern ColorPlum = HexColor #{const b2_colorPlum}
pattern ColorPowderBlue = HexColor #{const b2_colorPowderBlue}
pattern ColorPurple = HexColor #{const b2_colorPurple}
pattern ColorRebeccaPurple = HexColor #{const b2_colorRebeccaPurple}
pattern ColorRed = HexColor #{const b2_colorRed}
pattern ColorRosyBrown = HexColor #{const b2_colorRosyBrown}
pattern ColorRoyalBlue = HexColor #{const b2_colorRoyalBlue}
pattern ColorSaddleBrown = HexColor #{const b2_colorSaddleBrown}
pattern ColorSalmon = HexColor #{const b2_colorSalmon}
pattern ColorSandyBrown = HexColor #{const b2_colorSandyBrown}
pattern ColorSeaGreen = HexColor #{const b2_colorSeaGreen}
pattern ColorSeaShell = HexColor #{const b2_colorSeaShell}
pattern ColorSienna = HexColor #{const b2_colorSienna}
pattern ColorSilver = HexColor #{const b2_colorSilver}
pattern ColorSkyBlue = HexColor #{const b2_colorSkyBlue}
pattern ColorSlateBlue = HexColor #{const b2_colorSlateBlue}
pattern ColorSlateGray = HexColor #{const b2_colorSlateGray}
pattern ColorSnow = HexColor #{const b2_colorSnow}
pattern ColorSpringGreen = HexColor #{const b2_colorSpringGreen}
pattern ColorSteelBlue = HexColor #{const b2_colorSteelBlue}
pattern ColorTan = HexColor #{const b2_colorTan}
pattern ColorTeal = HexColor #{const b2_colorTeal}
pattern ColorThistle = HexColor #{const b2_colorThistle}
pattern ColorTomato = HexColor #{const b2_colorTomato}
pattern ColorTurquoise = HexColor #{const b2_colorTurquoise}
pattern ColorViolet = HexColor #{const b2_colorViolet}
pattern ColorWheat = HexColor #{const b2_colorWheat}
pattern ColorWhite = HexColor #{const b2_colorWhite}
pattern ColorWhiteSmoke = HexColor #{const b2_colorWhiteSmoke}
pattern ColorYellow = HexColor #{const b2_colorYellow}
pattern ColorYellowGreen = HexColor #{const b2_colorYellowGreen}
pattern ColorBox2DRed = HexColor #{const b2_colorBox2DRed}
pattern ColorBox2DBlue = HexColor #{const b2_colorBox2DBlue}
pattern ColorBox2DGreen = HexColor #{const b2_colorBox2DGreen}
pattern ColorBox2DYellow = HexColor #{const b2_colorBox2DYellow}

{-# COMPLETE ColorAliceBlue, ColorAntiqueWhite, ColorAqua, ColorAquamarine, ColorAzure, ColorBeige, ColorBisque, ColorBlack, ColorBlanchedAlmond, ColorBlue, ColorBlueViolet, ColorBrown, ColorBurlywood, ColorCadetBlue, ColorChartreuse, ColorChocolate, ColorCoral, ColorCornflowerBlue, ColorCornsilk, ColorCrimson, ColorCyan, ColorDarkBlue, ColorDarkCyan, ColorDarkGoldenRod, ColorDarkGray, ColorDarkGreen, ColorDarkKhaki, ColorDarkMagenta, ColorDarkOliveGreen, ColorDarkOrange, ColorDarkOrchid, ColorDarkRed, ColorDarkSalmon, ColorDarkSeaGreen, ColorDarkSlateBlue, ColorDarkSlateGray, ColorDarkTurquoise, ColorDarkViolet, ColorDeepPink, ColorDeepSkyBlue, ColorDimGray, ColorDodgerBlue, ColorFireBrick, ColorFloralWhite, ColorForestGreen, ColorFuchsia, ColorGainsboro, ColorGhostWhite, ColorGold, ColorGoldenRod, ColorGray, ColorGreen, ColorGreenYellow, ColorHoneyDew, ColorHotPink, ColorIndianRed, ColorIndigo, ColorIvory, ColorKhaki, ColorLavender, ColorLavenderBlush, ColorLawnGreen, ColorLemonChiffon, ColorLightBlue, ColorLightCoral, ColorLightCyan, ColorLightGoldenRodYellow, ColorLightGray, ColorLightGreen, ColorLightPink, ColorLightSalmon, ColorLightSeaGreen, ColorLightSkyBlue, ColorLightSlateGray, ColorLightSteelBlue, ColorLightYellow, ColorLime, ColorLimeGreen, ColorLinen, ColorMagenta, ColorMaroon, ColorMediumAquaMarine, ColorMediumBlue, ColorMediumOrchid, ColorMediumPurple, ColorMediumSeaGreen, ColorMediumSlateBlue, ColorMediumSpringGreen, ColorMediumTurquoise, ColorMediumVioletRed, ColorMidnightBlue, ColorMintCream, ColorMistyRose, ColorMoccasin, ColorNavajoWhite, ColorNavy, ColorOldLace, ColorOlive, ColorOliveDrab, ColorOrange, ColorOrangeRed, ColorOrchid, ColorPaleGoldenRod, ColorPaleGreen, ColorPaleTurquoise, ColorPaleVioletRed, ColorPapayaWhip, ColorPeachPuff, ColorPeru, ColorPink, ColorPlum, ColorPowderBlue, ColorPurple, ColorRebeccaPurple, ColorRed, ColorRosyBrown, ColorRoyalBlue, ColorSaddleBrown, ColorSalmon, ColorSandyBrown, ColorSeaGreen, ColorSeaShell, ColorSienna, ColorSilver, ColorSkyBlue, ColorSlateBlue, ColorSlateGray, ColorSnow, ColorSpringGreen, ColorSteelBlue, ColorTan, ColorTeal, ColorThistle, ColorTomato, ColorTurquoise, ColorViolet, ColorWheat, ColorWhite, ColorWhiteSmoke, ColorYellow, ColorYellowGreen, ColorBox2DRed, ColorBox2DBlue, ColorBox2DGreen, ColorBox2DYellow #-}



