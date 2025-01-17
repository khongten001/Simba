{
  Author: Raymond van Venetië and Merlijn Wajer
  Project: Simba (https://github.com/MerlijnWajer/Simba)
  License: GNU General Public License (https://www.gnu.org/licenses/gpl-3.0)

  Find things on a target.
}
unit simba.finder;

{$i simba.inc}

interface

uses
  Classes, SysUtils, Graphics,
  simba.base,
  simba.colormath, simba.colormath_distance,
  simba.image, simba.dtm, simba.target;

type
  PColorTolerance = ^TColorTolerance;
  TColorTolerance = record
    Color: TColor;
    Tolerance: Single;
    ColorSpace: EColorSpace;
    Multipliers: TChannelMultipliers;
  end;

  PSimbaFinder = ^TSimbaFinder;
  TSimbaFinder = packed record
  private
    FTarget: TSimbaTarget;

    function GetDataAsBitmap(var Bounds: TBox; out Bitmap: TSimbaImage): Boolean;
  public
    function FindDTMEx(DTM: TDTM; MaxToFind: Integer; Bounds: TBox): TPointArray;
    function FindDTMRotatedEx(DTM: TDTM; StartDegrees, EndDegrees: Double; Step: Double; out FoundDegrees: TDoubleArray; MaxToFind: Integer; Bounds: TBox): TPointArray;

    function FindDTM(DTM: TDTM; Bounds: TBox): TPoint;
    function FindDTMRotated(DTM: TDTM; StartDegrees, EndDegrees: Double; Step: Double; out FoundDegrees: TDoubleArray; Bounds: TBox): TPoint;

    function FindImageEx(Bitmap: TSimbaImage; Tolerance: Single; MaxToFind: Integer; Bounds: TBox): TPointArray; overload;
    function FindImageEx(Bitmap: TSimbaImage; Tolerance: Single; ColorSpace: EColorSpace; Multipliers: TChannelMultipliers; MaxToFind: Integer; Bounds: TBox): TPointArray; overload;

    function FindImage(Bitmap: TSimbaImage; Tolerance: Single; Bounds: TBox): TPoint; overload;
    function FindImage(Bitmap: TSimbaImage; Tolerance: Single; ColorSpace: EColorSpace; Multipliers: TChannelMultipliers; Bounds: TBox): TPoint; overload;

    function MatchColor(Color: TColor; ColorSpace: EColorSpace; Multipliers: TChannelMultipliers; Bounds: TBox): TSingleMatrix;

    function FindColor(Color: TColor; Tolerance: Single; Bounds: TBox): TPointArray; overload;
    function FindColor(Color: TColor; Tolerance: Single; ColorSpace: EColorSpace; Multipliers: TChannelMultipliers; Bounds: TBox): TPointArray; overload;
    function FindColor(Color: TColorTolerance; Bounds: TBox): TPointArray; overload;

    function CountColor(Color: TColor; Tolerance: Single; Bounds: TBox): Integer; overload;
    function CountColor(Color: TColor; Tolerance: Single; ColorSpace: EColorSpace; Multipliers: TChannelMultipliers; Bounds: TBox): Integer; overload;
    function CountColor(Color: TColorTolerance; Bounds: TBox): Integer; overload;

    function GetColor(X, Y: Integer): TColor;
    function GetColors(Points: TPointArray): TColorArray;
    function GetColorsMatrix(Bounds: TBox): TIntegerMatrix;

    function GetPixelDifference(WaitTime: Integer; Area: TBox): Integer; overload;
    function GetPixelDifference(WaitTime: Integer; Tolerance: Single; Area: TBox): Integer; overload;
    function GetPixelDifferenceTPA(WaitTime: Integer; Area: TBox): TPointArray; overload;
    function GetPixelDifferenceTPA(WaitTime: Integer; Tolerance: Single; Area: TBox): TPointArray; overload;

    function AverageBrightness(Area: TBox): Integer;
    function PeakBrightness(Area: TBox): Integer;

    function FindEdges(MinDiff: Single; ColorSpace: EColorSpace; Multipliers: TChannelMultipliers; Bounds: TBox): TPointArray; overload;
    function FindEdges(MinDiff: Single; Bounds: TBox): TPointArray; overload;

    function FindTemplate(Templ: TSimbaImage; MinMatch: Single; Bounds: TBox): TPoint;

    property Target: TSimbaTarget read FTarget write FTarget;

    class operator Initialize(var Self: TSimbaFinder);
  end;

implementation

uses
  simba.matrix_float, simba.matrix_int, simba.array_point,
  simba.finder_color, simba.finder_image, simba.finder_dtm,
  simba.arraybuffer, simba.matchtemplate;

function TSimbaFinder.GetDataAsBitmap(var Bounds: TBox; out Bitmap: TSimbaImage): Boolean;
var
  Data: PColorBGRA = nil;
  DataWidth: Integer;
  Y: Integer;
begin
  Result := FTarget.GetImageData(Bounds, Data, DataWidth);

  if Result then
  begin
    Bitmap := TSimbaImage.Create(Bounds.Width, Bounds.Height);
    for Y := 0 to Bitmap.Height - 1 do
      Move(Data[Y * DataWidth], Bitmap.Data[Y * Bitmap.Width], Bitmap.Width * SizeOf(TColorBGRA));

    FTarget.FreeImageData(Data);
  end;
end;

function TSimbaFinder.FindDTMEx(DTM: TDTM; MaxToFind: Integer; Bounds: TBox): TPointArray;
begin
  Result := FindDTMOnTarget(FTarget, DTM, Bounds, MaxToFind);
end;

function TSimbaFinder.FindDTMRotatedEx(DTM: TDTM; StartDegrees, EndDegrees: Double; Step: Double; out FoundDegrees: TDoubleArray; MaxToFind: Integer; Bounds: TBox): TPointArray;
begin
  Result := FindDTMRotatedOnTarget(FTarget, DTM, StartDegrees, EndDegrees, Step, FoundDegrees, Bounds, MaxToFind);
end;

function TSimbaFinder.FindDTM(DTM: TDTM; Bounds: TBox): TPoint;
var
  TPA: TPointArray;
begin
  TPA := FindDTMOnTarget(FTarget, DTM, Bounds, 1);
  if (Length(TPA) > 0) then
    Result := TPA[0]
  else
    Result := TPoint.Create(-1, -1);
end;

function TSimbaFinder.FindDTMRotated(DTM: TDTM; StartDegrees, EndDegrees: Double; Step: Double; out FoundDegrees: TDoubleArray; Bounds: TBox): TPoint;
var
  TPA: TPointArray;
begin
  TPA := FindDTMRotatedOnTarget(FTarget, DTM, StartDegrees, EndDegrees, Step, FoundDegrees, Bounds, 1);
  if (Length(TPA) > 0) then
    Result := TPA[0]
  else
    Result := TPoint.Create(-1, -1);
end;

function TSimbaFinder.FindImageEx(Bitmap: TSimbaImage; Tolerance: Single; MaxToFind: Integer; Bounds: TBox): TPointArray;
begin
  Result := FindBitmapOnTarget(FTarget, Bitmap, Bounds, DefaultColorSpace, Tolerance, DefaultMultipliers, MaxToFind);
end;

function TSimbaFinder.FindImageEx(Bitmap: TSimbaImage; Tolerance: Single; ColorSpace: EColorSpace; Multipliers: TChannelMultipliers; MaxToFind: Integer; Bounds: TBox): TPointArray;
begin
  Result := FindBitmapOnTarget(FTarget, Bitmap, Bounds, ColorSpace, Tolerance, Multipliers, MaxToFind);
end;

function TSimbaFinder.FindImage(Bitmap: TSimbaImage; Tolerance: Single; Bounds: TBox): TPoint;
var
  TPA: TPointArray;
begin
  TPA := FindBitmapOnTarget(FTarget, Bitmap, Bounds, DefaultColorSpace, Tolerance, DefaultMultipliers, 1);
  if (Length(TPA) > 0) then
    Result := TPA[0]
  else
    Result := TPoint.Create(-1, -1);
end;

function TSimbaFinder.FindImage(Bitmap: TSimbaImage; Tolerance: Single; ColorSpace: EColorSpace; Multipliers: TChannelMultipliers; Bounds: TBox): TPoint;
var
  TPA: TPointArray;
begin
  TPA := FindBitmapOnTarget(FTarget, Bitmap, Bounds, ColorSpace, Tolerance, Multipliers, 1);
  if (Length(TPA) > 0) then
    Result := TPA[0]
  else
    Result := TPoint.Create(-1, -1);
end;

function TSimbaFinder.MatchColor(Color: TColor; ColorSpace: EColorSpace; Multipliers: TChannelMultipliers; Bounds: TBox): TSingleMatrix;
begin
  Result := MatchColorsOnTarget(FTarget, Bounds, ColorSpace, Color, Multipliers);
end;

function TSimbaFinder.FindColor(Color: TColor; Tolerance: Single; Bounds: TBox): TPointArray;
begin
  Result := FindColorsOnTarget(FTarget, Bounds, DefaultColorSpace, Color, Tolerance, DefaultMultipliers);
end;

function TSimbaFinder.FindColor(Color: TColor; Tolerance: Single; ColorSpace: EColorSpace; Multipliers: TChannelMultipliers; Bounds: TBox): TPointArray;
begin
  Result := FindColorsOnTarget(FTarget, Bounds, ColorSpace, Color, Tolerance, Multipliers);
end;

function TSimbaFinder.FindColor(Color: TColorTolerance; Bounds: TBox): TPointArray;
begin
  Result := FindColorsOnTarget(FTarget, Bounds, Color.ColorSpace, Color.Color, Color.Tolerance, Color.Multipliers);
end;

function TSimbaFinder.CountColor(Color: TColor; Tolerance: Single; Bounds: TBox): Integer;
begin
  Result := CountColorsOnTarget(FTarget, Bounds, DefaultColorSpace, Color, Tolerance, DefaultMultipliers);
end;

function TSimbaFinder.CountColor(Color: TColor; Tolerance: Single; ColorSpace: EColorSpace; Multipliers: TChannelMultipliers; Bounds: TBox): Integer;
begin
  Result := CountColorsOnTarget(FTarget, Bounds, ColorSpace, Color, Tolerance, Multipliers);
end;

function TSimbaFinder.CountColor(Color: TColorTolerance; Bounds: TBox): Integer;
begin
  Result := CountColorsOnTarget(FTarget, Bounds, Color.ColorSpace, Color.Color, Color.Tolerance, Color.Multipliers);
end;

function TSimbaFinder.GetColor(X, Y: Integer): TColor;
var
  B: TBox;
  Data: PColorBGRA;
  DataWidth: Integer;
begin
  Result := -1;

  B.X1 := X; B.Y1 := Y;
  B.X2 := X; B.Y2 := Y;

  if FTarget.GetImageData(B, Data, DataWidth) then
  try
    Result := Data^.R or Data^.G shl G_BIT or Data^.B shl B_BIT;
  finally
    FTarget.FreeImageData(Data);
  end;
end;

function TSimbaFinder.GetColors(Points: TPointArray): TColorArray;
var
  B: TBox;
  Data: PColorBGRA;
  DataWidth: Integer;
  I, Count: Integer;
  Pixel: TColorBGRA;
begin
  Result := nil;

  B := Points.Bounds();
  if FTarget.GetImageData(B, Data, DataWidth) then
  try
    SetLength(Result, Length(Points));

    Count := 0;
    for I := 0 to High(Points) do
    begin
      Pixel := Data[(Points[I].Y - B.Y1) * DataWidth + (Points[I].X - B.X1)];

      Result[Count] := Pixel.R or Pixel.G shl G_BIT or Pixel.B shl B_BIT;
      Inc(Count);
    end;
    SetLength(Result, Count);
  finally
    FTarget.FreeImageData(Data);
  end;
end;

function TSimbaFinder.GetColorsMatrix(Bounds: TBox): TIntegerMatrix;
var
  Data: PColorBGRA;
  DataWidth: Integer;
  Width, Height, X, Y: Integer;
  Pixel: TColorBGRA;
begin
  Result := nil;

  if FTarget.GetImageData(Bounds, Data, DataWidth) then
  try
    Width := Bounds.Width - 1;
    Height := Bounds.Height - 1;

    Result.SetSize(Width + 1, Height + 1);

    for Y := 0 to Height do
      for X := 0 to Width do
      begin
        Pixel := Data[Y * DataWidth + X];

        Result[Y, X] := Pixel.R or Pixel.G shl G_BIT or Pixel.B shl B_BIT;
      end;
  finally
    FTarget.FreeImageData(Data);
  end;
end;

function TSimbaFinder.GetPixelDifference(WaitTime: Integer; Area: TBox): Integer;
var
  BitmapBefore, BitmapAfter: TSimbaImage;
begin
  Result := 0;

  BitmapBefore := nil;
  BitmapAfter := nil;

  if GetDataAsBitmap(Area, BitmapBefore) then
  try
    Sleep(WaitTime);
    if GetDataAsBitmap(Area, BitmapAfter) and (BitmapBefore.Width = BitmapAfter.Width) and (BitmapBefore.Height = BitmapAfter.Height) then
      Result := BitmapBefore.PixelDifference(BitmapAfter);
  finally
    if (BitmapBefore <> nil) then
      BitmapBefore.Free();
    if (BitmapAfter <> nil) then
      BitmapAfter.Free();
  end;
end;

function TSimbaFinder.GetPixelDifference(WaitTime: Integer; Tolerance: Single; Area: TBox): Integer;
var
  BitmapBefore, BitmapAfter: TSimbaImage;
begin
  Result := 0;

  BitmapBefore := nil;
  BitmapAfter := nil;

  if GetDataAsBitmap(Area, BitmapBefore) then
  try
    Sleep(WaitTime);
    if GetDataAsBitmap(Area, BitmapAfter) and (BitmapBefore.Width = BitmapAfter.Width) and (BitmapBefore.Height = BitmapAfter.Height) then
      Result := BitmapBefore.PixelDifference(BitmapAfter, Tolerance);
  finally
    if (BitmapBefore <> nil) then
      BitmapBefore.Free();
    if (BitmapAfter <> nil) then
      BitmapAfter.Free();
  end;
end;

function TSimbaFinder.GetPixelDifferenceTPA(WaitTime: Integer; Area: TBox): TPointArray;
var
  BitmapBefore, BitmapAfter: TSimbaImage;
begin
  Result := nil;

  BitmapBefore := nil;
  BitmapAfter := nil;

  if GetDataAsBitmap(Area, BitmapBefore) then
  try
    Sleep(WaitTime);
    if GetDataAsBitmap(Area, BitmapAfter) and (BitmapBefore.Width = BitmapAfter.Width) and (BitmapBefore.Height = BitmapAfter.Height) then
      Result := BitmapBefore.PixelDifferenceTPA(BitmapAfter);
  finally
    if (BitmapBefore <> nil) then
      BitmapBefore.Free();
    if (BitmapAfter <> nil) then
      BitmapAfter.Free();
  end;
end;

function TSimbaFinder.GetPixelDifferenceTPA(WaitTime: Integer; Tolerance: Single; Area: TBox): TPointArray;
var
  BitmapBefore, BitmapAfter: TSimbaImage;
begin
  Result := nil;

  BitmapBefore := nil;
  BitmapAfter := nil;

  if GetDataAsBitmap(Area, BitmapBefore) then
  try
    Sleep(WaitTime);
    if GetDataAsBitmap(Area, BitmapAfter) and (BitmapBefore.Width = BitmapAfter.Width) and (BitmapBefore.Height = BitmapAfter.Height) then
      Result := BitmapBefore.PixelDifferenceTPA(BitmapAfter, Tolerance);
  finally
    if (BitmapBefore <> nil) then
      BitmapBefore.Free();
    if (BitmapAfter <> nil) then
      BitmapAfter.Free();
  end;
end;

function TSimbaFinder.AverageBrightness(Area: TBox): Integer;
var
  Bitmap: TSimbaImage;
  X, Y, Sum: Integer;
begin
  Result := 0;

  if GetDataAsBitmap(Area, Bitmap) then
  try
    for Y := 0 to Bitmap.Height - 1 do
    begin
      Sum := 0;
      for X := 0 to Bitmap.Width - 1 do
        with Bitmap.Data[Y * Bitmap.Width + X] do
          Sum += Round((R + G + B) / 3 * 0.392);

      Result += Sum div Bitmap.Width;
    end;

    Result := Round(Result / Bitmap.Height);
  finally
    Bitmap.Free();
  end;
end;

function TSimbaFinder.PeakBrightness(Area: TBox): Integer;
var
  Bitmap: TSimbaImage;
  X, Y: Integer;
begin
  Result := 0;

  if GetDataAsBitmap(Area, Bitmap) then
  try
    for Y := 0 to Bitmap.Height - 1 do
      for X := 0 to Bitmap.Width - 1 do
        with Bitmap.Data[Y * Bitmap.Width + X] do
        begin
          if (R > Result) then Result := R;
          if (G > Result) then Result := G;
          if (B > Result) then Result := B;
        end;

    Result := Round(Result / 255 * 100);
  finally
    Bitmap.Free();
  end;
end;

function TSimbaFinder.FindEdges(MinDiff: Single; ColorSpace: EColorSpace; Multipliers: TChannelMultipliers; Bounds: TBox): TPointArray;
var
  Bitmap: TSimbaImage;
  X, Y ,W, H: Integer;
  Buffer: TSimbaPointBuffer;
  First, Second, Third: TColor;
begin
  Buffer.Init();

  if GetDataAsBitmap(Bounds, Bitmap) then
  try
    W := Bitmap.Width - 2;
    H := Bitmap.Height - 2;

    for Y := 0 to H do
      for X := 0 to W do
      begin
        First  := Bitmap.Data[Y*Bitmap.Width+X].ToColor();
        Second := Bitmap.Data[Y*Bitmap.Width+(X+1)].ToColor();
        Third  := Bitmap.Data[(Y+1)*Bitmap.Width+X].ToColor();

        if (not SimilarColors(First, Second, MinDiff, ColorSpace, Multipliers)) or
           (not SimilarColors(First, Third, MinDiff, ColorSpace, Multipliers)) then
        begin
          Buffer.Add(X, Y);

          Continue;
        end;
      end;
  finally
    Bitmap.Free();
  end;

  Result := Buffer.ToArray(False);
end;

function TSimbaFinder.FindEdges(MinDiff: Single; Bounds: TBox): TPointArray;
begin
  Result := FindEdges(MinDiff, DefaultColorSpace, DefaultMultipliers, Bounds);
end;

function TSimbaFinder.FindTemplate(Templ: TSimbaImage; MinMatch: Single; Bounds: TBox): TPoint;
var
  Bitmap: TSimbaImage;
  Mat: TSingleMatrix;
  Best: TPoint;
begin
  Result := TPoint.Create(-1, -1);

  if GetDataAsBitmap(Bounds, Bitmap) then
  try
    Mat := Bitmap.MatchTemplate(Templ, TM_CCOEFF_NORMED);

    Best := Mat.ArgMax();
    if (Mat[Best.Y, Best.X] >= MinMatch) then
      Result := Best + Bounds.TopLeft;
  finally
    Bitmap.Free();
  end;
end;

class operator TSimbaFinder.Initialize(var Self: TSimbaFinder);
begin
  Self := Default(TSimbaFinder);
end;

end.


