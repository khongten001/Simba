{
  Author: Raymond van Venetië and Merlijn Wajer
  Project: Simba (https://github.com/MerlijnWajer/Simba)
  License: GNU General Public License (https://www.gnu.org/licenses/gpl-3.0)
}
unit simba.image;

{$DEFINE SIMBA_MAX_OPTIMIZATION}
{$i simba.inc}

interface

uses
  Classes, SysUtils, Graphics,
  simba.baseclass, simba.base, simba.image_textdrawer,
  simba.colormath, simba.colormath_distance, simba.matchtemplate,
  simba.circle, simba.quad;

type
  {$PUSH}
  {$SCOPEDENUMS ON}
  ESimbaImageMirrorStyle = (WIDTH, HEIGHT, LINE);
  ESimbaImageThreshMethod = (MEAN, MIN_MAX);
  {$POP}

  TSimbaImageRowPtrs = array of PColorBGRA;

  PSimbaImage = ^TSimbaImage;
  TSimbaImage = class(TSimbaBaseClass)
  protected
    FWidth: Integer;
    FHeight: Integer;

    FTransparentColorActive: Boolean;
    FTransparentRGB: TColorBGRA;
    FTransparentColor: TColor;

    FData: PColorBGRA;
    FDataOwner: Boolean;

    FTextDrawer: TSimbaTextDrawer;

    procedure _DrawTPA(const TPA: TPointArray; Color: TColor);
    procedure _DrawTPAAlpha(const TPA: TPointArray; Color: TColor; Alpha: Byte);

    procedure _DrawBoxFilled(Box: TBox; Color: TColor);
    procedure _DrawBoxFilledAlpha(Box: TBox; Color: TColor; Alpha: Byte);

    procedure _DrawCircleFilledAlpha(ACenter: TPoint; Radius: Integer; Color: TColor; Alpha: Byte);
    procedure _DrawCircleFilled(ACenter: TPoint; Radius: Integer; Color: TColor);

    procedure _DrawPolygonFilledAlpha(Points: TPointArray; Color: TColor; Alpha: Byte);
    procedure _DrawPolygonFilled(Points: TPointArray; Color: TColor);

    procedure NotifyUnfreed; override;

    function GetPixel(X, Y: Integer): TColor;
    function GetCenter: TPoint;
    function GetFontAntialiasing: Boolean;
    function GetFontName: String;
    function GetFontSize: Single;
    function GetFontBold: Boolean;
    function GetFontItalic: Boolean;

    procedure SetPixel(X, Y: Integer; Color: TColor);
    procedure SetTransparentColor(Value: TColor);
    procedure SetFontAntialiasing(Value: Boolean);
    procedure SetFontName(Value: String);
    procedure SetFontSize(Value: Single);
    procedure SetFontBold(Value: Boolean);
    procedure SetFontItalic(Value: Boolean);
  public
    class var SaveUnfreedImages: ShortString;
    class function LoadFonts(Dir: String): Boolean;
    class function LoadedFontNames: TStringArray;
  public
    constructor Create; overload;
    constructor Create(AWidth, AHeight: Integer); overload;
    constructor CreateFromFile(FileName: String);
    constructor CreateFromZip(ZipFileName, ZipEntryName: String);
    constructor CreateFromString(Str: String);
    constructor CreateFromData(AWidth, AHeight: Integer; AData: PColorBGRA; ADataWidth: Integer);
    constructor CreateFromWindow(Window: TWindowHandle);

    destructor Destroy; override;

    property Data: PColorBGRA read FData write FData;
    property DataOwner: Boolean read FDataOwner write FDataOwner;
    property Width: Integer read FWidth;
    property Height: Integer read FHeight;
    property Center: TPoint read GetCenter;

    property TransparentColorActive: Boolean read FTransparentColorActive write FTransparentColorActive;
    property TransparentColor: TColor read FTransparentColor write SetTransparentColor;
    property TransparentRGB: TColorBGRA read FTransparentRGB;

    property Pixel[X, Y: Integer]: TColor read GetPixel write SetPixel; default;

    property FontName: String read GetFontName write SetFontName;
    property FontSize: Single read GetFontSize write SetFontSize;
    property FontAntialiasing: Boolean read GetFontAntialiasing write SetFontAntialiasing;
    property FontBold: Boolean read GetFontBold write SetFontBold;
    property FontItalic: Boolean read GetFontItalic write SetFontItalic;

    function InImage(const X, Y: Integer): Boolean; overload;
    procedure AssertInImage(const Method: String; const X, Y: Integer);

    function Equals(Other: TObject): Boolean; override;
    function Equals(Other: TSimbaImage): Boolean; overload;

    function TextWidth(Text: String): Integer;
    function TextHeight(Text: String): Integer;
    function TextSize(Text: String): TPoint;

    procedure DrawText(Text: String; Position: TPoint; Color: TColor); overload;
    procedure DrawText(Text: String; Box: TBox; ACenter: Boolean; Color: TColor); overload;
    procedure DrawTextLines(Text: TStringArray; Position: TPoint; Color: TColor);

    procedure SetSize(NewWidth, NewHeight: Integer);

    function ResizeNN(NewWidth, NewHeight: Integer): TSimbaImage;
    function ResizeBilinear(NewWidth, NewHeight: Integer): TSimbaImage;

    function RotateNN(Radians: Single; Expand: Boolean): TSimbaImage;
    function RotateBilinear(Radians: Single; Expand: Boolean): TSimbaImage;

    function GetPixels(Points: TPointArray): TColorArray;
    procedure SetPixels(Points: TPointArray; Colors: TColorArray);

    procedure SetExternalData(AData: PColorBGRA; AWidth, AHeight: Integer);
    procedure ResetExternalData;

    procedure DrawATPA(const ATPA: T2DPointArray; Color: TColor = -1; Alpha: Byte = 0);
    procedure DrawTPA(const TPA: TPointArray; Color: TColor; Alpha: Byte = 0);

    // Line
    procedure DrawCrosshairs(ACenter: TPoint; Size: Integer; Color: TColor);
    procedure DrawCross(ACenter: TPoint; Radius: Integer; Color: TColor);
    procedure DrawLine(Start, Stop: TPoint; Color: TColor);

    // Box
    procedure DrawBox(B: TBox; Color: TColor);
    procedure DrawBoxFilled(Box: TBox; Color: TColor; Alpha: Byte = 0);
    procedure DrawBoxInverted(B: TBox; Color: TColor);

    // Poly
    procedure DrawPolygon(Points: TPointArray; Color: TColor);
    procedure DrawPolygonFilled(Points: TPointArray; Color: TColor; Alpha: Byte = 0);
    procedure DrawPolygonInverted(Points: TPointArray; Color: TColor);

    // Quad
    procedure DrawQuad(Quad: TQuad; Color: TColor);
    procedure DrawQuadFilled(Quad: TQuad; Color: TColor; Alpha: Byte = 0);
    procedure DrawQuadInverted(Quad: TQuad; Color: TColor);

    // Circle
    procedure DrawCircle(ACenter: TPoint; Radius: Integer; Color: TColor);
    procedure DrawCircleInverted(ACenter: TPoint; Radius: Integer; Color: TColor);
    procedure DrawCircleFilled(ACenter: TPoint; Radius: Integer; Color: TColor; Alpha: Byte = 0);

    // TCircle overloads
    procedure DrawCircle(Circle: TCircle; Color: TColor); overload;
    procedure DrawCircleFilled(Circle: TCircle; Color: TColor; Alpha: Byte = 0); overload;
    procedure DrawCircleInverted(Circle: TCircle; Color: TColor); overload;

    // Antialiased
    procedure DrawLineAA(Start, Stop: TPoint; Color: TColor; Thickness: Single = 1.5);
    procedure DrawEllipseAA(ACenter: TPoint; XRadius, YRadius: Integer; Color: TColor; Thickness: Single = 1.5);
    procedure DrawCircleAA(ACenter: TPoint; Radius: Integer; Color: TColor; Thickness: Single = 1.5);

    procedure DrawQuadArray(Quads: TQuadArray; Filled: Boolean; Color: TColor = -1);
    procedure DrawBoxArray(Boxes: TBoxArray; Filled: Boolean; Color: TColor = -1);
    procedure DrawPolygonArray(Polygons: T2DPointArray; Filled: Boolean; Color: TColor = -1);
    procedure DrawCircleArray(Centers: TPointArray; Radius: Integer; Filled: Boolean; Color: TColor = -1); overload;
    procedure DrawCircleArray(Circles: TCircleArray; Filled: Boolean; Color: TColor = -1); overload;
    procedure DrawCrossArray(Points: TPointArray; Radius: Integer; Color: TColor = -1);

    procedure DrawHSLCircle(ACenter: TPoint; Radius: Integer);

    procedure DrawMatrix(Matrix: TIntegerMatrix); overload;
    procedure DrawMatrix(Matrix: TSingleMatrix; ColorMapID: Integer = 0); overload;

    procedure Fill(Color: TColor);

    procedure Clear;
    procedure Clear(Area: TBox);
    procedure ClearInverted(Area: TBox);

    procedure Draw(Image: TSimbaImage; X, Y: Integer); overload;
    procedure Draw(Image: TSimbaImage; Position: TPoint); overload;

    function GetColors: TColorArray;
    procedure ReplaceColor(OldColor, NewColor: TColor);
    procedure ReplaceColors(OldColors, NewColors: TColorArray);

    function GreyScale: TSimbaImage;
    function Brightness(Value: Integer): TSimbaImage;
    function Invert: TSimbaImage;
    function Posterize(Value: Integer): TSimbaImage;
    function Convolute(Matrix: TDoubleMatrix): TSimbaImage;
    function Mirror(Style: ESimbaImageMirrorStyle): TSimbaImage;
    function BoxBlur(Radius: Integer): TSimbaImage;
    function GaussBlur(Radius: Double): TSimbaImage;
    function Blend(Points: TPointArray; Radius: Integer): TSimbaImage;
    function Downsample(Scale: Integer): TSimbaImage;

    function Copy(X1, Y1, X2, Y2: Integer): TSimbaImage; overload;
    function Copy: TSimbaImage; overload;

    procedure Crop(X1, Y1, X2, Y2: Integer);
    procedure Pad(Amount: Integer);

    function ToLazBitmap: TBitmap;
    procedure LoadFromLazBitmap(LazBitmap: TBitmap);

    function ToGreyMatrix: TByteMatrix;
    function ToMatrixBGR: TIntegerMatrix;
    function ToMatrix: TIntegerMatrix; overload;
    function ToMatrix(X1, Y1, X2, Y2: Integer): TIntegerMatrix; overload;

    function ThresholdAdaptive(Alpha, Beta: Byte; AInvert: Boolean; Method: ESimbaImageThreshMethod; K: Integer): TSimbaImage;
    function ThresholdSauvola(Radius: Integer; AInvert: Boolean = False; R: Single = 128; K: Single = 0.5): TSimbaImage;

    function RowPtrs: TSimbaImageRowPtrs;

    function SaveToFile(FileName: String; OverwriteIfExists: Boolean = False): Boolean;
    function SaveToString: String;

    procedure LoadFromStream(Stream: TStream; FileName: String);
    procedure LoadFromFile(FileName: String); overload;
    procedure LoadFromFile(FileName: String; Area: TBox); overload;
    procedure LoadFromString(Str: String);
    procedure LoadFromData(AWidth, AHeight: Integer; AData: PColorBGRA; ADataWidth: Integer);
    procedure LoadFromImage(Image: TSimbaImage);

    function Compare(Other: TSimbaImage): Single;

    function PixelDifference(Other: TSimbaImage): Integer; overload;
    function PixelDifference(Other: TSimbaImage; Tolerance: Single): Integer; overload;
    function PixelDifferenceTPA(Other: TSimbaImage): TPointArray; overload;
    function PixelDifferenceTPA(Other: TSimbaImage; Tolerance: Single): TPointArray; overload;

    function MatchTemplate(Template: TSimbaImage; Formula: ETMFormula): TSingleMatrix;
    function MatchTemplateMask(Template: TSimbaImage; Formula: ETMFormula): TSingleMatrix;
  end;

  TSimbaImageArray = array of TSimbaImage;

implementation

uses
  Math, FPImage, fpqoi_simba,
  simba.matrix_float, simba.matrix_int, simba.array_point,
  simba.arraybuffer, simba.geometry, simba.algo_sort,
  simba.encoding, simba.compress,
  simba.nativeinterface,
  simba.image_lazbridge, simba.image_integral, simba.image_gaussblur,
  simba.image_bitmaparealoader, simba.image_utils, simba.files;

function TSimbaImage.SaveToFile(FileName: String; OverwriteIfExists: Boolean): Boolean;
var
  Stream: TFileStream;
  WriterClass: TFPCustomImageWriterClass;
begin
  Result := False;

  if FileExists(FileName) and (not OverwriteIfExists) then
    SimbaException('TSimbaImage.SaveToFile: File already exists "%s"', [FileName]);

  WriterClass := TFPCustomImage.FindWriterFromFileName(FileName);
  if (WriterClass = nil) then
    SimbaException('TSimbaImage.SaveToFile: Unknown image format "%s"', [FileName]);

  Stream := nil;
  try
    if FileExists(FileName) then
      Stream := TFileStream.Create(FileName, fmOpenReadWrite or fmShareDenyWrite)
    else
      Stream := TFileStream.Create(FileName, fmCreate or fmShareDenyWrite);

    SimbaImage_ToFPImageWriter(Self, WriterClass, Stream);

    Result := True;
  finally
    if (Stream <> nil) then
      Stream.Free();
  end;
end;

procedure TSimbaImage.LoadFromFile(FileName: String);
var
  ReaderClass: TFPCustomImageReaderClass;
  Stream: TFileStream;
begin
  if (not FileExists(FileName)) then
    SimbaException('TSimbaImage.LoadFromFile: File "%s" does not exist', [FileName]);

  ReaderClass := TFPCustomImage.FindReaderFromFileName(FileName);
  if (ReaderClass = nil) then
    SimbaException('TSimbaImage.LoadFromFile: Unknown image format "%s"', [FileName]);

  Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    SimbaImage_FromFPImageReader(Self, ReaderClass, Stream);
  finally
    Stream.Free();
  end;
end;

procedure TSimbaImage.LoadFromFile(FileName: String; Area: TBox);
begin
  if (not FileExists(FileName)) then
    SimbaException('TSimbaImage.LoadFromFile: File not found "%s"', [FileName]);

  if FileName.EndsWith('.bmp', False) then
    SimbaImage_LoadBitmapArea(Self, FileName, Area)
  else
  begin
    LoadFromFile(FileName);

    Area := Area.Clip(TBox.Create(0, 0, FWidth - 1, FHeight - 1));
    if (Area.Width > 1) and (Area.Height > 1) then
      Crop(Area.X1, Area.Y1, Area.X2, Area.Y2);
  end;
end;

function TSimbaImage.Copy: TSimbaImage;
begin
  Result := TSimbaImage.Create();
  Result.SetSize(FWidth, FHeight);

  Move(FData^, Result.FData^, FWidth * FHeight * SizeOf(TColorBGRA));
end;

function TSimbaImage.Copy(X1, Y1, X2, Y2: Integer): TSimbaImage;
var
  Y: Integer;
begin
  AssertInImage('Copy', X1, Y1);
  AssertInImage('Copy', X2, Y2);

  Result := TSimbaImage.Create();
  Result.SetSize(X2-X1+1, Y2-Y1+1);
  for Y := Y1 to Y2 do
    Move(FData[Y * FWidth + X1], Result.FData[(Y-Y1) * Result.FWidth], Result.FWidth * SizeOf(TColorBGRA));
end;

procedure TSimbaImage.Crop(X1, Y1, X2, Y2: Integer);
var
  Y: Integer;
begin
  AssertInImage('Crop', X1, Y1);
  AssertInImage('Crop', X2, Y2);

  for Y := Y1 to Y2 do
    Move(FData[Y * FWidth + X1], FData[(Y-Y1) * FWidth], FWidth * SizeOf(TColorBGRA));

  SetSize(X2-X1+1, Y2-Y1+1);
end;

function TSimbaImage.ToLazBitmap: TBitmap;
begin
  Result := SimbaImage_ToLazImage(Self);
end;

function TSimbaImage.ToGreyMatrix: TByteMatrix;
var
  X, Y: Integer;
begin
  Result.SetSize(FWidth, FHeight);

  for Y := 0 to FHeight - 1 do
    for X := 0 to FWidth - 1 do
      with FData[Y * FWidth + X] do
        Result[Y, X] := Round(R * 0.3 + G * 0.59 + B * 0.11);
end;

function TSimbaImage.ToMatrixBGR: TIntegerMatrix;
var
  Y: Integer;
begin
  Result.SetSize(FWidth, FHeight);
  for Y := 0 to FHeight - 1 do
    Move(FData[Y * FWidth], Result[Y, 0], FWidth * SizeOf(Integer));
end;

function TSimbaImage.ToMatrix: TIntegerMatrix;
var
  X, Y, W, H: Integer;
begin
  Result.SetSize(Width, Height);

  W := FWidth - 1;
  H := FHeight - 1;

  for Y := 0 to H do
    for X := 0 to W do
      Result[Y][X] := FData[Y * FWidth + X].ToColor();
end;

function TSimbaImage.ToMatrix(X1, Y1, X2, Y2: Integer): TIntegerMatrix;
var
  X, Y: Integer;
begin
  AssertInImage('ToMatrix', X1, Y1);
  AssertInImage('ToMatrix', X2, Y2);

  Result.SetSize(X2-X1+1, Y2-Y1+1);

  for Y := Y1 to Y2 do
    for X := X1 to X2 do
      Result[Y-Y1, X-X1] := FData[Y * FWidth + X].ToColor();
end;

procedure TSimbaImage.DrawMatrix(Matrix: TIntegerMatrix);
var
  X, Y, W, H: Integer;
begin
  SetSize(Matrix.Width, Matrix.Height);

  W := FWidth - 1;
  H := FHeight - 1;

  for Y := 0 to H do
    for X := 0 to W do
      FData[Y * FWidth + X] := ColorToBGRA(Matrix[Y, X]);
end;

procedure TSimbaImage.DrawMatrix(Matrix: TSingleMatrix; ColorMapID: Integer = 0); overload;
var
  X,Y, W,H: TColor;
  Normed: TSingleMatrix;
  HSL: TColorHSL;
begin
  SetSize(Matrix.Width, Matrix.Height);

  Normed := Matrix.NormMinMax(0, 1);

  W := FWidth - 1;
  H := FHeight - 1;

  HSL := Default(TColorHSL);

  for Y := 0 to H do
    for X := 0 to W do
    begin
      case ColorMapID of
        0:begin //cold blue to red
            HSL.H := (1 - Normed[Y,X]) * 240;
            HSL.S := 40 + Normed[Y,X] * 60;
            HSL.L := 50;
          end;
        1:begin //black -> blue -> red
            HSL.H := (1 - Normed[Y,X]) * 240;
            HSL.S := 100;
            HSL.L := Normed[Y,X] * 50;
          end;
        2:begin //white -> blue -> red
            HSL.H := (1 - Normed[Y,X]) * 240;
            HSL.S := 100;
            HSL.L := 100 - Normed[Y,X] * 50;
          end;
        3:begin //Light (to white)
            HSL.L := (1 - Normed[Y,X]) * 100;
          end;
        4:begin //Light (to black)
            HSL.L := Normed[Y,X] * 100;
          end;
        else
          begin //Custom black to hue to white
            HSL.H := ColorMapID;
            HSL.S := 100;
            HSL.L := Normed[Y,X] * 100;
          end;
      end;

      FData[Y*FWidth+X] := TColorBGRA(HSL.ToColor.ToBGRA());
    end;
end;

function TSimbaImage.RowPtrs: TSimbaImageRowPtrs;
var
  I: Integer;
begin
  SetLength(Result, FHeight);
  for I := 0 to High(Result) do
    Result[I] := @FData[FWidth * I];
end;

function TSimbaImage.SaveToString: String;
const
  Header = 'IMG:';
var
  Stream: TStringStream;
begin
  Stream := TStringStream.Create();
  try
    SimbaImage_ToFPImageWriter(Self, TFPWriterQoi, Stream);

    Result := Header + Base64Encode(ZCompressString(Stream.DataString));
  finally
    Stream.Free();
  end;
end;

procedure TSimbaImage.LoadFromStream(Stream: TStream; FileName: String);
var
  ReaderClass: TFPCustomImageReaderClass;
begin
  ReaderClass := TFPCustomImage.FindReaderFromFileName(FileName);
  if (ReaderClass = nil) then
    SimbaException('TSimbaImage.LoadFromStream: Unknown image format "%s"', [FileName]);

  SimbaImage_FromFPImageReader(Self, ReaderClass, Stream);
end;

procedure TSimbaImage.LoadFromString(Str: String);
const
  HEADER = 'IMG:';
var
  Stream: TStringStream;
begin
  if not Str.StartsWith(HEADER, True) then
    SimbaException('TImage.LoadFromString: Invalid string "' + Str + '"');
  Str := Str.After(HEADER);

  Stream := TStringStream.Create(ZDecompressString(Base64Decode(Str)));
  try
    SimbaImage_FromFPImageReader(Self, TFPReaderQoi, Stream);
  finally
    Stream.Free();
  end;
end;

procedure TSimbaImage.LoadFromData(AWidth, AHeight: Integer; AData: PColorBGRA; ADataWidth: Integer);
var
  Y: Integer;
begin
  SetSize(AWidth, AHeight);
  if (AData = nil) then
    Exit;

  if (ADataWidth <> AWidth) then
  begin
    for Y := 0 to AHeight - 1 do
      Move(AData[Y * ADataWidth], FData[Y * FWidth], FWidth * SizeOf(TColorBGRA))
  end else
    Move(AData^, FData^, FWidth * FHeight * SizeOf(TColorBGRA));
end;

// TM_CCOEFF_NORMED
// Author: slackydev
function TSimbaImage.Compare(Other: TSimbaImage): Single;
var
  invSize, sigmaR, sigmaG, sigmaB, isum, tsum: Single;
  x, y, W, H: Integer;
  tcR, tcG, tcB, icR, icG, icB: TSingleMatrix;
begin
  if (FWidth <> Other.Width) or (FHeight <> Other.Height) then
    SimbaException('TSimbaImage.Compare: Both images must be equal dimensions');

  invSize := 1 / (FWidth * FHeight);

  // compute T' for template
  tcR.SetSize(FWidth, FHeight);
  tcG.SetSize(FWidth, FHeight);
  tcB.SetSize(FWidth, FHeight);

  sigmaR := 0;
  sigmaG := 0;
  sigmaB := 0;

  W := FWidth - 1;
  H := FHeight - 1;
  for y:=0 to H do
    for x:=0 to W do
      with Other.Data[y*FWidth+x] do
      begin
        sigmaR += R;
        sigmaG += G;
        sigmaB += B;
      end;

  for y:=0 to H do
    for x:=0 to W do
      with Other.Data[y*FWidth+x] do
      begin
        tcR[y,x] := R - invSize * sigmaR;
        tcG[y,x] := G - invSize * sigmaG;
        tcB[y,x] := B - invSize * sigmaB;
      end;

  // compute I' for image
  icR.SetSize(Width, Height);
  icG.SetSize(Width, Height);
  icB.SetSize(Width, Height);

  sigmaR := 0;
  sigmaG := 0;
  sigmaB := 0;

  for y:=0 to H do
    for x:=0 to W do
      with FData[y*Width+x] do
      begin
        sigmaR += R;
        sigmaG += G;
        sigmaB += B;
      end;

  for y:=0 to H do
    for x:=0 to W do
      with FData[y*Width+x] do
      begin
        icR[y,x] := R - invsize * sigmaR;
        icG[y,x] := G - invsize * sigmaG;
        icB[y,x] := B - invsize * sigmaB;
      end;

  // ccoeff
  Result := 0;
  for y:=0 to H do
    for x:=0 to W do
      Result += ((icR[y,x] * tcR[y,x]) + (icG[y,x] * tcG[y,x]) + (icB[y,x] * tcB[y,x]));

  isum := 0;
  tsum := 0;
  for y:=0 to H do
    for x:=0 to W do
    begin
      isum += Sqr(icR[y,x]) + Sqr(icG[y,x]) + Sqr(icB[y,x]);
      tsum += Sqr(tcR[y,x]) + Sqr(tcG[y,x]) + Sqr(tcB[y,x]);
    end;
  Result := Result / Sqrt(isum * tsum);
end;

function TSimbaImage.PixelDifference(Other: TSimbaImage): Integer;
var
  I: Integer;
  Ptr, OtherPtr: PColorBGRA;
begin
  Result := 0;
  if (FWidth <> Other.Width) or (FHeight <> Other.Height) then
    SimbaException('TSimbaImage.PixelDifference: Both images must be equal dimensions');

  Ptr := Data;
  OtherPtr := Other.Data;

  for I := 0 to FWidth * FHeight - 1 do
  begin
    if not Ptr^.EqualsIgnoreAlpha(OtherPtr^) then
      Inc(Result);

    Inc(Ptr);
    Inc(OtherPtr);
  end;
end;

function TSimbaImage.PixelDifference(Other: TSimbaImage; Tolerance: Single): Integer;
var
  I: Integer;
  Ptr, OtherPtr: PColorBGRA;
begin
  Result := 0;
  if (FWidth <> Other.Width) or (FHeight <> Other.Height) then
    SimbaException('TSimbaImage.PixelDifference: Both images must be equal dimensions');
  if (Tolerance = 0) then
    Exit(PixelDifference(Other));

  Tolerance := Sqr(Tolerance);

  Ptr := Data;
  OtherPtr := Other.Data;

  for I := 0 to FWidth * FHeight - 1 do
  begin
    if (not SimilarColors(Ptr^.ToColor(), OtherPtr^.ToColor(), Tolerance)) then
      Inc(Result);

    Inc(Ptr);
    Inc(OtherPtr);
  end;
end;

function TSimbaImage.PixelDifferenceTPA(Other: TSimbaImage): TPointArray;
var
  X, Y, W, H: Integer;
  Index: Integer;
  Buffer: TSimbaPointBuffer;
begin
  if (FWidth <> Other.Width) or (FHeight <> Other.Height) then
    SimbaException('TSimbaImage.PixelDifference: Both images must be equal dimensions');
  Buffer.Init();

  W := FWidth - 1;
  H := FHeight - 1;

  for Y := 0 to H do
    for X := 0 to W do
    begin
      Index := Y * FWidth + X;
      if not FData[Index].EqualsIgnoreAlpha(Other.FData[Index]) then
        Buffer.Add(TPoint.Create(X, Y));
    end;

  Result := Buffer.ToArray(False);
end;

function TSimbaImage.PixelDifferenceTPA(Other: TSimbaImage; Tolerance: Single): TPointArray;
var
  X, Y, W, H: Integer;
  Index: Integer;
  Buffer: TSimbaPointBuffer;
begin
  if (FWidth <> Other.Width) or (FHeight <> Other.Height) then
    SimbaException('TSimbaImage.PixelDifference: Both images must be equal dimensions');
  if (Tolerance = 0) then
    Exit(PixelDifferenceTPA(Other));

  Buffer.Init();

  Tolerance := Sqr(Tolerance);

  W := FWidth - 1;
  H := FHeight - 1;

  for Y := 0 to H do
    for X := 0 to W do
    begin
      Index := Y * FWidth + X;
      if (not (SimilarColors(FData[Index].ToColor(), Other.FData[Index].ToColor(), Tolerance))) then
        Buffer.Add(TPoint.Create(X, Y));
    end;

  Result := Buffer.ToArray(False);
end;

procedure TSimbaImage.LoadFromLazBitmap(LazBitmap: TBitmap);
var
  TempBitmap: TSimbaImage;
begin
  SetSize(0, 0);

  TempBitmap := LazImage_ToSimbaImage(LazBitmap);
  TempBitmap.DataOwner := False;

  FData := TempBitmap.Data;
  FWidth := TempBitmap.Width;
  FHeight := TempBitmap.Height;

  TempBitmap.Free();
end;

procedure TSimbaImage.LoadFromImage(Image: TSimbaImage);
begin
  SetSize(Image.Width, Image.Height);

  Move(Image.FData^, FData^, FWidth * FHeight * SizeOf(TColorBGRA));
end;

procedure TSimbaImage.DrawTPA(const TPA: TPointArray; Color: TColor; Alpha: Byte);
begin
  if (Alpha = 0) then
    _DrawTPA(TPA, Color)
  else
    _DrawTPAAlpha(TPA, Color, Alpha);
end;

procedure TSimbaImage.DrawATPA(const ATPA: T2DPointArray; Color: TColor; Alpha: Byte);
var
  I: Integer;
begin
  for I := 0 to High(ATPA) do
    DrawTPA(ATPA[I], GetDistinctColor(Color, I), Alpha);
end;

procedure TSimbaImage.DrawCrosshairs(ACenter: TPoint; Size: Integer; Color: TColor);
begin
  Size := Max(1, Size);

  with ACenter do
  begin
    Self.DrawLine(Point(X - Size, Y), Point(X + Size, Y), Color);
    Self.DrawLine(Point(X, Y - Size), Point(X, Y + Size), Color);
  end;
end;

procedure TSimbaImage.DrawCross(ACenter: TPoint; Radius: Integer; Color: TColor);
begin
  Radius := Max(1, Round(Radius/2*Sqrt(2)));

  with ACenter do
  begin
    Self.DrawLine(Point(X - Radius, Y - Radius), Point(X + Radius, Y + Radius), Color);
    Self.DrawLine(Point(X + Radius, Y - Radius), Point(X - Radius, Y + Radius), Color);
  end;
end;

procedure TSimbaImage.DrawLine(Start, Stop: TPoint; Color: TColor);
var
  BGR: TColorBGRA;

  procedure PutPixel(const X, Y: Single); inline;
  var
    XX, YY: Integer;
  begin
    XX := Round(X);
    YY := Round(Y);
    if (XX >= 0) and (YY >= 0) and (XX < FWidth) and (YY < FHeight) then
      FData[YY * FWidth + XX] := BGR;
  end;

var
  DX, DY, Step, I: Integer;
  RX, RY, X, Y: Single;
begin
  BGR := ColorToBGRA(Color);

  DX := (Stop.X - Start.X);
  DY := (Stop.Y - Start.Y);
  if (Abs(DX) > Abs(DY)) then
    Step := Abs(DX)
  else
    Step := Abs(DY);

  if (Step = 0) then
  begin
    RX := DX;
    RY := DY;
  end else
  begin
    RX := DX / Step;
    RY := DY / Step;
  end;
  X := Start.X;
  Y := Start.Y;

  PutPixel(X, Y);
  for I := 1 to Step do
  begin
    X := X + RX;
    Y := Y + RY;

    PutPixel(X, Y);
  end;
end;

procedure TSimbaImage.DrawPolygon(Points: TPointArray; Color: TColor);
begin
  Self.DrawTPA(Points.Connect(), Color);
end;

procedure TSimbaImage.DrawPolygonFilled(Points: TPointArray; Color: TColor; Alpha: Byte);
begin
  if (Length(Points) = 0) then
    Exit;

  if (Alpha > 0) then
    _DrawPolygonFilledAlpha(Points, Color, Alpha)
  else
    _DrawPolygonFilled(Points, Color);
end;

procedure TSimbaImage.DrawPolygonInverted(Points: TPointArray; Color: TColor);
var
  X, Y, Hi: Integer;
  Bounds: TBox;
  RGB: TColorBGRA;
begin
  Hi := High(Points);
  if (Hi < 0) then
    Exit;
  RGB := ColorToBGRA(Color);

  Bounds := Points.Bounds().Clip(Box(0, 0, FWidth-1, FHeight-1));

  Self.DrawBoxInverted(Bounds, Color);

  for X := Bounds.X1 to Bounds.X2 do
    for Y := Bounds.Y1 to Bounds.Y2 do
      if not TSimbaGeometry.PointInPolygon(Point(X, Y), Points) then
        FData[Y*FWidth+X] := RGB;
end;

procedure TSimbaImage.DrawCircle(ACenter: TPoint; Radius: Integer; Color: TColor);

  procedure _SetPixel(const X, Y: Integer); inline;
  begin
    if (X >= 0) and (Y >= 0) and (X < FWidth) and (Y < FHeight) then
      FData[Y*FWidth+X].AsInteger := Color;
  end;

  {$i circle.inc}

begin
  if (Radius < 1) then
    Exit;
  Color := Color.ToBGRA().AsInteger; // rgb to bgr

  _Circle(ACenter.X, ACenter.Y, Radius);
end;

procedure TSimbaImage.DrawCircle(Circle: TCircle; Color: TColor);
begin
  DrawCircle(Circle.Center, Circle.Radius, Color);
end;

procedure TSimbaImage.DrawCircleFilled(ACenter: TPoint; Radius: Integer; Color: TColor; Alpha: Byte = 0);
begin
  if (Radius < 1) then
    Exit;

  if (Alpha > 0) then
    _DrawCircleFilledAlpha(ACenter, Radius, Color, Alpha)
  else
    _DrawCircleFilled(ACenter, Radius, Color);
end;

procedure TSimbaImage.DrawCircleFilled(Circle: TCircle; Color: TColor; Alpha: Byte = 0);
begin
  DrawCircleFilled(Circle.Center, Circle.Radius, Color, Alpha);
end;

procedure TSimbaImage.DrawCircleInverted(ACenter: TPoint; Radius: Integer; Color: TColor);
var
  X, Y: Integer;
  B: TBox;
  RGB: TColorBGRA;
begin
  RGB := ColorToBGRA(Color);

  B.X1 := Max(ACenter.X-Radius, 0);
  B.Y1 := Max(ACenter.Y-Radius, 0);
  B.X2 := Min(ACenter.X+Radius, FWidth-1);
  B.Y2 := Min(ACenter.Y+Radius, FHeight-1);

  Self.DrawBoxInverted(B, Color);

  for X := B.X1 to B.X2 do
    for Y := B.Y1 to B.Y2 do
      if not TSimbaGeometry.PointInCircle(TPoint.Create(X,Y), ACenter, Radius) then
        FData[Y*FWidth+X] := RGB;
end;

procedure TSimbaImage.DrawCircleInverted(Circle: TCircle; Color: TColor);
begin
  DrawCircleInverted(Circle.Center, Circle.Radius, Color);
end;

procedure TSimbaImage.DrawBox(B: TBox; Color: TColor);
begin
  Self.DrawTPA(TPointArray.CreateFromBox(B, False), Color);
end;

procedure TSimbaImage.DrawBoxFilled(Box: TBox; Color: TColor; Alpha: Byte);
begin
  Box := Box.Clip(TBox.Create(0, 0, FWidth-1, FHeight-1));
  if (Box.X2 - Box.X1 < 1) or (Box.Y2 - Box.Y1 < 1) then
    Exit;

  if (Alpha > 0) then
    _DrawBoxFilledAlpha(Box, Color, Alpha)
  else
    _DrawBoxFilled(Box, Color);
end;

procedure TSimbaImage.DrawBoxInverted(B: TBox; Color: TColor);
begin
  Self.DrawBoxFilled(Box(0,    0,    B.X1,     B.Y1),      Color); //Top Left
  Self.DrawBoxFilled(Box(0,    B.Y1, B.X1,     B.Y2),      Color); //Mid Left
  Self.DrawBoxFilled(Box(0,    B.Y1, B.X1,     FHeight-1), Color); //Btm Left
  Self.DrawBoxFilled(Box(B.X1, 0,    B.X2,     B.Y1),      Color); //Top Mid
  Self.DrawBoxFilled(Box(B.X1, B.Y2, B.X2,     FHeight-1), Color); //Btm Mid
  Self.DrawBoxFilled(Box(B.X2, 0,    FWidth-1, B.Y1),      Color); //Top Right
  Self.DrawBoxFilled(Box(B.X2, B.Y1, FWidth-1, B.Y2),      Color); //Mid Right
  Self.DrawBoxFilled(Box(B.X2, B.Y1, FWidth-1, FHeight-1), Color); //Btm Right
end;

procedure TSimbaImage.DrawQuad(Quad: TQuad; Color: TColor);
begin
  DrawLine(Quad.Top, Quad.Right, Color);
  DrawLine(Quad.Right, Quad.Bottom, Color);
  DrawLine(Quad.Bottom, Quad.Left, Color);
  DrawLine(Quad.Left, Quad.Top, Color);
end;

procedure TSimbaImage.DrawQuadFilled(Quad: TQuad; Color: TColor; Alpha: Byte);
begin
  DrawPolygonFilled([Quad.Top, Quad.Right, Quad.Bottom, Quad.Left], Color, Alpha);
end;

procedure TSimbaImage.DrawQuadInverted(Quad: TQuad; Color: TColor);
var
  X, Y: Integer;
  Bounds: TBox;
  RGB: TColorBGRA;
begin
  RGB := Color.ToBGRA();

  Bounds := Quad.Bounds.Clip(Box(0, 0, FWidth-1, FHeight-1));

  Self.DrawBoxInverted(Bounds, Color);

  for X := Bounds.X1 to Bounds.X2 do
    for Y := Bounds.Y1 to Bounds.Y2 do
      if not TSimbaGeometry.PointInQuad(TPoint.Create(X, Y), Quad.Top, Quad.Right, Quad.Bottom, Quad.Left) then
        FData[Y*FWidth+X] := RGB;
end;

procedure TSimbaImage.DrawQuadArray(Quads: TQuadArray; Filled: Boolean; Color: TColor);
var
  I: Integer;
begin
  for I := 0 to High(Quads) do
    if Filled then
      DrawQuadFilled(Quads[I], GetDistinctColor(Color, I))
    else
      DrawQuad(Quads[I], GetDistinctColor(Color, I));
end;

procedure TSimbaImage.DrawBoxArray(Boxes: TBoxArray; Filled: Boolean; Color: TColor);
var
  I: Integer;
begin
  for I := 0 to High(Boxes) do
    if Filled then
      DrawBoxFilled(Boxes[I], GetDistinctColor(Color, I))
    else
      DrawBox(Boxes[I], GetDistinctColor(Color, I));
end;

procedure TSimbaImage.DrawPolygonArray(Polygons: T2DPointArray; Filled: Boolean; Color: TColor);
var
  I: Integer;
begin
  for I := 0 to High(Polygons) do
    if Filled then
      DrawPolygonFilled(Polygons[I], GetDistinctColor(Color, I))
    else
      DrawPolygon(Polygons[I], GetDistinctColor(Color, I));
end;

procedure TSimbaImage.DrawCircleArray(Centers: TPointArray; Radius: Integer; Filled: Boolean; Color: TColor);
var
  I: Integer;
begin
  for I := 0 to High(Centers) do
    if Filled then
      DrawCircleFilled(Centers[I], Radius, GetDistinctColor(Color, I))
    else
      DrawCircle(Centers[I], Radius, GetDistinctColor(Color, I));
end;

procedure TSimbaImage.DrawCircleArray(Circles: TCircleArray; Filled: Boolean; Color: TColor);
var
  I: Integer;
begin
  for I := 0 to High(Circles) do
    if Filled then
      DrawCircleFilled(Circles[I], GetDistinctColor(Color, I))
    else
      DrawCircle(Circles[I], GetDistinctColor(Color, I));
end;

procedure TSimbaImage.DrawCrossArray(Points: TPointArray; Radius: Integer; Color: TColor);
var
  I: Integer;
begin
  for I := 0 to High(Points) do
    DrawCross(Points[I], Radius, GetDistinctColor(Color, I));
end;

procedure TSimbaImage.DrawHSLCircle(ACenter: TPoint; Radius: Integer);
var
  HSL: TColorHSL;
  X, Y: Integer;
  Bounds: TBox;
begin
  Bounds.X1 := Max(ACenter.X - Radius, 0);
  Bounds.Y1 := Max(ACenter.Y - Radius, 0);
  Bounds.X2 := Min(ACenter.X + Radius, FWidth - 1);
  Bounds.Y2 := Min(ACenter.Y + Radius, FHeight - 1);

  for Y := Bounds.Y1 to Bounds.Y2 do
    for X := Bounds.X1 to Bounds.X2 do
    begin
      HSL.H := RadToDeg(ArcTan2(Y - ACenter.Y, X - ACenter.X));
      HSL.S := Hypot(ACenter.X - X, ACenter.Y - Y) / Radius * 100;
      HSL.L := 50;
      if (HSL.S < 100) then
        SetPixel(X, Y, HSL.ToColor());
    end;
end;

procedure TSimbaImage.Fill(Color: TColor);
begin
  FillData(@FData[0], FWidth * FHeight, Color.ToBGRA());
end;

procedure TSimbaImage.Clear;
begin
  DrawBoxFilled(Box(0, 0, FWidth-1, FHeight-1), FTransparentColor);
end;

procedure TSimbaImage.Clear(Area: TBox);
begin
  DrawBoxFilled(Area, FTransparentColor);
end;

procedure TSimbaImage.ClearInverted(Area: TBox);
begin
  DrawBoxInverted(Area, FTransparentColor);
end;

procedure TSimbaImage.Draw(Image: TSimbaImage; X, Y: Integer);
var
  LoopX, LoopY, W, H: Integer;
  DestX, DestY: Integer;
  Color: TColorBGRA;
begin
  W := Image.Width - 1;
  H := Image.Height - 1;

  for LoopY := 0 to H do
    for LoopX := 0 to W do
    begin
      DestX := LoopX + X;
      DestY := LoopY + Y;

      if (DestX >= 0) and (DestY >= 0) and (DestX < FWidth) and (DestY < FHeight) then
      begin
        Color := Image.Data[LoopY * Image.Width + LoopX];
        if (Image.TransparentColorActive) and (not Color.EqualsIgnoreAlpha(Image.TransparentRGB)) then
          FData[DestY * FWidth + DestX] := Image.FData[LoopY * Image.Width + LoopX];
      end;
    end;
end;

procedure TSimbaImage.Draw(Image: TSimbaImage; Position: TPoint);
begin
  Draw(Image, Position.X, Position.Y);
end;

function TSimbaImage.GetColors: TColorArray;
var
  I: Integer;
begin
  SetLength(Result, FHeight * FWidth);
  for I := 0 to High(Result) do
    Result[I] := FData[I].ToColor();
end;

function TSimbaImage.Equals(Other: TObject): Boolean;
begin
  if (Other is TSimbaImage) then
    Result := Equals(TSimbaImage(Other))
  else
    Result := inherited Equals(Other);
end;

function TSimbaImage.Equals(Other: TSimbaImage): Boolean;
begin
  Result := (FWidth  = Other.FWidth) and
            (FHeight = Other.FHeight) and
            (CompareMem(FData, Other.FData, FWidth * FHeight * SizeOf(TColorBGRA)));
end;

class function TSimbaImage.LoadFonts(Dir: String): Boolean;
begin
  Result := SimbaFreeTypeFontLoader.LoadFonts(Dir);
end;

procedure TSimbaImage.ReplaceColor(OldColor, NewColor: TColor);
var
  Old, New: TColorBGRA;
  Ptr: PColorBGRA;
  Upper: PtrUInt;
begin
  Old := OldColor.ToBGRA();
  New := NewColor.ToBGRA();

  Upper := PtrUInt(@FData[FWidth * FHeight]);
  Ptr := FData;

  while (PtrUInt(Ptr) < Upper) do
  begin
    if Ptr^.EqualsIgnoreAlpha(Old) then
      Ptr^ := New;

    Inc(Ptr);
  end;
end;

procedure TSimbaImage.ReplaceColors(OldColors, NewColors: TColorArray);
var
  I, H: Integer;
  Arr: array of record
    Old, New: TColorBGRA;
  end;
  Ptr: PColorBGRA;
  Upper: PtrUInt;
begin
  if (Length(OldColors) <> Length(NewColors)) then
    SimbaException('TSimbaImage.ReplaceColors: Color arrays must be same lengths (%d, %s)', [Length(OldColors), Length(NewColors)]);

  SetLength(Arr, Length(OldColors));
  for I := 0 to High(Arr) do
  begin
    Arr[I].Old := OldColors[I].ToBGRA();
    Arr[I].New := NewColors[I].ToBGRA();
  end;

  H := High(Arr);
  Upper := PtrUInt(@FData[FWidth * FHeight]);
  Ptr := FData;

  while (PtrUInt(Ptr) < Upper) do
  begin
    for I := 0 to H do
      if Ptr^.EqualsIgnoreAlpha(Arr[I].Old) then
        Ptr^ := Arr[I].New;

    Inc(Ptr);
  end;
end;

function TSimbaImage.RotateNN(Radians: Single; Expand: Boolean): TSimbaImage;
var
  CosAngle, SinAngle: Single;

  procedure RotateNoExpand;
  var
    X, Y, OldX, OldY, W, H: Integer;
    MidX, MidY: Single;
  begin
    Result.SetSize(FWidth, FHeight);

    MidX := (FWidth - 1) / 2;
    MidY := (FHeight - 1) / 2;

    W := FWidth - 1;
    H := FHeight - 1;
    for Y := 0 to H do
      for X := 0 to W do
      begin
        OldX := Round(MidX + CosAngle * (X - MidX) - SinAngle * (Y - MidY));
        OldY := Round(MidY + SinAngle * (X - MidX) + CosAngle * (Y - MidY));
        if (OldX >= 0) and (OldX < FWidth) and (OldY >= 0) and (OldY < FHeight) then
          Result.FData[Y * FWidth + X] := FData[OldY * FWidth + OldX];
      end;
  end;

  procedure RotateExpand;
  var
    X, Y, OldX, OldY, NewWidth, NewHeight: Integer;
    MidX, MidY: Single;
    NewBounds: TBox;
  begin
    MidX := (FWidth - 1) / 2;
    MidY := (FHeight - 1) / 2;

    NewBounds := GetRotatedSize(FWidth, FHeight, Radians);

    NewWidth := NewBounds.Width-1;
    NewHeight := NewBounds.Height-1;

    Result.SetSize(NewWidth, NewHeight);

    Dec(NewWidth);
    Dec(NewHeight);
    for Y := 0 to NewHeight do
      for X := 0 to NewWidth do
      begin
        OldX := Round(MidX + CosAngle * (NewBounds.X1+X - MidX) - SinAngle * (NewBounds.Y1+Y - MidY));
        OldY := Round(MidY + SinAngle * (NewBounds.X1+X - MidX) + CosAngle * (NewBounds.Y1+Y - MidY));
        if (OldX >= 0) and (OldX < FWidth) and (OldY >= 0) and (OldY < FHeight) then
          Result.FData[Y * Result.FWidth + X] := FData[OldY * FWidth + OldX];
      end;
  end;

begin
  Result := TSimbaImage.Create();

  SinCos(Radians, SinAngle, CosAngle);

  case Expand of
    True:  RotateExpand();
    False: RotateNoExpand();
  end;
end;

function TSimbaImage.RotateBilinear(Radians: Single; Expand: Boolean): TSimbaImage;
var
  CosAngle, SinAngle: Single;

  procedure RotateNoExpand;
  var
    x, y, w, h: Integer;
    OldX, OldY: Single;
    dX, dY, dxMinus1, dyMinus1: Single;
    p0, p1, p2, p3: TColorBGRA;
    topR, topG, topB, BtmR, btmG, btmB: Single;
    fX, fY, cX, cY: Integer;
    MidX, MidY: Single;
  begin
    Result.SetSize(FWidth, FHeight);

    MidX := (FWidth - 1) / 2;
    MidY := (FHeight - 1) / 2;

    W := FWidth - 1;
    H := FHeight - 1;
    for Y := 0 to H do
      for X := 0 to W do
      begin
        OldX := (MidX + CosAngle * (X - MidX) - SinAngle * (Y - MidY));
        OldY := (MidY + SinAngle * (X - MidX) + CosAngle * (Y - MidY));

        fX := Trunc(OldX);
        fY := Trunc(OldY);
        cX := Ceil(OldX);
        cY := Ceil(OldY);

        if (fX >= 0) and (cX >= 0) and (fX < FWidth) and (cX < FWidth) and
           (fY >= 0) and (cY >= 0) and (fY < FHeight) and (cY < FHeight) then
        begin
          dx := OldX - fX;
          dy := OldY - fY;
          dxMinus1 := 1 - dx;
          dyMinus1 := 1 - dy;

          p0 := FData[fY * FWidth + fX];
          p1 := FData[fY * FWidth + cX];
          p2 := FData[cY * FWidth + fX];
          p3 := FData[cY * FWidth + cX];

          TopR := dxMinus1 * p0.R + dx * p1.R;
          TopG := dxMinus1 * p0.G + dx * p1.G;
          TopB := dxMinus1 * p0.B + dx * p1.B;
          BtmR := dxMinus1 * p2.R + dx * p3.R;
          BtmG := dxMinus1 * p2.G + dx * p3.G;
          BtmB := dxMinus1 * p2.B + dx * p3.B;

          with Result.Data[Y * Result.Width + X] do
          begin
            R := EnsureRange(Round(dyMinus1 * TopR + dy * BtmR), 0, 255);
            G := EnsureRange(Round(dyMinus1 * TopG + dy * BtmG), 0, 255);
            B := EnsureRange(Round(dyMinus1 * TopB + dy * BtmB), 0, 255);
            A := 0;
          end;
        end;
      end;
  end;

  procedure RotateExpand;
  var
    NewWidth, NewHeight, X, Y: Integer;
    NewBounds: TBox;
    OldX, OldY: Single;
    dX, dY, dxMinus1, dyMinus1: Single;
    p0, p1, p2, p3: TColorBGRA;
    topR, topG, topB, BtmR, btmG, btmB: Single;
    fX, fY, cX, cY: Integer;
    MidX, MidY: Single;
  begin
    NewBounds := GetRotatedSize(FWidth, FHeight, Radians);
    NewWidth := NewBounds.Width - 1;
    NewHeight := NewBounds.Height - 1;
    MidX := (NewWidth - 1) / 2;
    MidY := (NewHeight - 1) / 2;

    Result.SetSize(NewWidth, NewHeight);

    Dec(NewWidth);
    Dec(NewHeight);
    for Y := 0 to NewHeight do
      for X := 0 to NewWidth do
      begin
        OldX := (MidX + CosAngle * (X - MidX) - SinAngle * (Y - MidY));
        OldY := (MidY + SinAngle * (X - MidX) + CosAngle * (Y - MidY));

        fX := Trunc(OldX) + NewBounds.X1;
        fY := Trunc(OldY) + NewBounds.Y1;
        cX := Ceil(OldX)  + NewBounds.X1;
        cY := Ceil(OldY)  + NewBounds.Y1;

        if (fX >= 0) and (cX >= 0) and (fX < FWidth) and (cX < FWidth) and
           (fY >= 0) and (cY >= 0) and (fY < FHeight) and (cY < FHeight) then
        begin
          dx := OldX - (fX - NewBounds.X1);
          dy := OldY - (fY - NewBounds.Y1);
          dxMinus1 := 1 - dx;
          dyMinus1 := 1 - dy;

          p0 := FData[fY * FWidth + fX];
          p1 := FData[fY * FWidth + cX];
          p2 := FData[cY * FWidth + fX];
          p3 := FData[cY * FWidth + cX];

          TopR := dxMinus1 * p0.R + dx * p1.R;
          TopG := dxMinus1 * p0.G + dx * p1.G;
          TopB := dxMinus1 * p0.B + dx * p1.B;
          BtmR := dxMinus1 * p2.R + dx * p3.R;
          BtmG := dxMinus1 * p2.G + dx * p3.G;
          BtmB := dxMinus1 * p2.B + dx * p3.B;

          with Result.Data[Y * Result.Width + X] do
          begin
            R := EnsureRange(Round(dyMinus1 * TopR + dy * BtmR), 0, 255);
            G := EnsureRange(Round(dyMinus1 * TopG + dy * BtmG), 0, 255);
            B := EnsureRange(Round(dyMinus1 * TopB + dy * BtmB), 0, 255);
            A := 0;
          end;
        end;
      end;
  end;

begin
  Result := TSimbaImage.Create();

  SinCos(Radians, SinAngle, CosAngle);

  case Expand of
    True:  RotateExpand();
    False: RotateNoExpand();
  end;
end;

function TSimbaImage.GreyScale: TSimbaImage;
var
  I: Integer;
  Src, Dest: PColorBGRA;
  Lum: Byte;
begin
  Result := TSimbaImage.Create(FWidth, FHeight);

  Src := FData;
  Dest := Result.Data;

  for i := (FHeight * FWidth - 1) downto 0 do
  begin
    Lum := Round(Src^.R * 0.3 + Src^.G * 0.59 + Src^.B * 0.11);

    Dest^.R := Lum;
    Dest^.G := Lum;
    Dest^.B := Lum;

    Inc(Src);
    Inc(Dest);
  end;
end;

function TSimbaImage.Brightness(Value: Integer): TSimbaImage;
var
  I: Integer;
  Src, Dest: PColorBGRA;
begin
  Result := TSimbaImage.Create(FWidth, FHeight);

  Src := FData;
  Dest := Result.Data;

  for I := (FHeight * FWidth - 1) downto 0 do
  begin
    Dest^.R := EnsureRange(Src^.R + Value, 0, 255);
    Dest^.G := EnsureRange(Src^.G + Value, 0, 255);
    Dest^.B := EnsureRange(Src^.B + Value, 0, 255);

    Inc(Src);
    Inc(Dest);
  end;
end;

function TSimbaImage.Invert: TSimbaImage;
var
  I: Integer;
  Src, Dest: PColorBGRA;
begin
  Result := TSimbaImage.Create(FWidth, FHeight);

  Src := FData;
  Dest := Result.Data;

  for I := (FHeight * FWidth - 1) downto 0 do
  begin
    Dest^.R := not Src^.R;
    Dest^.G := not Src^.G;
    Dest^.B := not Src^.B;

    Inc(Src);
    Inc(Dest);
  end;
end;

function TSimbaImage.Posterize(Value: Integer): TSimbaImage;
var
  I: Integer;
  Src, Dest: PColorBGRA;
begin
  if not InRange(Value, 1, 255) then
    SimbaException('TSimbaImage.Posterize: Value(%d) out of range[1..255]', [Value]);

  Result := TSimbaImage.Create(FWidth, FHeight);

  Src := FData;
  Dest := Result.Data;

  for I := (FHeight * FWidth - 1) downto 0 do
  begin
    Dest^.R := Min(Round(Src^.R / Value) * Value, 255);
    Dest^.G := Min(Round(Src^.G / Value) * Value, 255);
    Dest^.B := Min(Round(Src^.B / Value) * Value, 255);

    Inc(Src);
    Inc(Dest);
  end;
end;

function TSimbaImage.BoxBlur(Radius: Integer): TSimbaImage;
var
  X, Y, W, H: Integer;
  XX, YY: Integer;
  Size: Integer;
  B: TBox;
  Sum: record
    R,G,B: UInt64;
  end;
  Ptr: PColorBGRA;
begin
  Result := TSimbaImage.Create(FWidth, FHeight);
  if (Radius <= 1) or (not Odd(Radius)) then
    SimbaException('TSimbaImage.BlockBlur: Radius(%d) must be odd (1,3,5 etc).', [Radius]);

  Radius := Radius div 2;

  W := FWidth - 1;
  H := FHeight - 1;

  for Y := 0 to H do
    for X := 0 to W do
    begin
      B.X1 := Max(X-Radius, 0);
      B.Y1 := Max(Y-Radius, 0);
      B.X2 := Min(X+Radius, W);
      B.Y2 := Min(Y+Radius, H);

      Size := 0;
      Sum.R := 0; Sum.G := 0; Sum.B := 0;

      for YY := B.Y1 to B.Y2 - 1 do
        for XX := B.X1 to B.X2 - 1 do
        begin
          Ptr := @FData[YY * FWidth + XX];

          Sum.R += Ptr^.R;
          Sum.G += Ptr^.G;
          Sum.B += Ptr^.B;
          Size += 1;
        end;

      Ptr := @Result.Data[Y * FWidth + X];
      Ptr^.R := Sum.R div Size;
      Ptr^.G := Sum.G div Size;
      Ptr^.B := Sum.B div Size;
    end;
end;

function TSimbaImage.Convolute(Matrix: TDoubleMatrix): TSimbaImage;
var
  X, Y, YY, XX, CX, CY: Integer;
  SrcRows, DestRows: TSimbaImageRowPtrs;
  MatWidth, MatHeight, MidX, MidY: Integer;
  NewR, NewG, NewB: Double;
begin
  Result := TSimbaImage.Create(FWidth, FHeight);

  SrcRows := RowPtrs;
  DestRows := Result.RowPtrs;

  if Matrix.GetSize(MatWidth, MatHeight) then
  begin
    MidX := MatWidth div 2;
    MidY := MatHeight div 2;

    MatWidth -= 1;
    MatHeight -= 1;

    for Y := 0 to FHeight - 1 do
      for X := 0 to FWidth - 1 do
      begin
        NewR := 0;
        NewG := 0;
        NewB := 0;

        for YY := 0 to MatHeight do
          for XX := 0 to MatWidth do
          begin
            CX := EnsureRange(X+XX-MidX, 0, FWidth-1);
            CY := EnsureRange(Y+YY-MidY, 0, FHeight-1);

            NewR += (Matrix[YY, XX] * SrcRows[CY, CX].R);
            NewG += (Matrix[YY, XX] * SrcRows[CY, CX].G);
            NewB += (Matrix[YY, XX] * SrcRows[CY, CX].B);
          end;

        DestRows[Y, X].R := Round(NewR);
        DestRows[Y, X].G := Round(NewG);
        DestRows[Y, X].B := Round(NewB);
      end;
  end;
end;

function TSimbaImage.Mirror(Style: ESimbaImageMirrorStyle): TSimbaImage;
var
  X, Y: Integer;
begin
  case Style of
    ESimbaImageMirrorStyle.WIDTH:
      begin
        Result := TSimbaImage.Create(FWidth, FHeight);

        for Y := FHeight - 1 downto 0 do
          for X := FWidth - 1 downto 0 do
            Result.FData[Y*FWidth+X] := FData[Y*FWidth+FWidth-1-X];
      end;

    ESimbaImageMirrorStyle.HEIGHT:
      begin
        Result := TSimbaImage.Create(FWidth, FHeight);

        for Y := FHeight - 1 downto 0 do
          Move(FData[Y*FWidth], Result.FData[(FHeight-1-Y) * FWidth], FWidth * SizeOf(TColorBGRA));
      end;

    ESimbaImageMirrorStyle.LINE:
      begin
        Result := TSimbaImage.Create(FHeight, FWidth);

        for Y := FHeight - 1 downto 0 do
          for X := FHeight - 1 downto 0 do
            Result.FData[X*FHeight+Y] := FData[Y*FWidth+X];
      end;
  end;
end;

function TSimbaImage.GaussBlur(Radius: Double): TSimbaImage;
var
  r,g,b: TByteArray;
  i: Integer;
  ptr: PColorBGRA;
  ptrR, ptrG, ptrB: PByte;
begin
  Result := TSimbaImage.Create(FWidth, FHeight);
  if (FWidth = 0) or (FHeight = 0) then
    Exit;

  SetLength(r, FWidth*FHeight);
  SetLength(g, FWidth*FHeight);
  SetLength(b, FWidth*FHeight);

  ptr := FData;
  ptrR := @r[0];
  ptrG := @g[0];
  ptrB := @b[0];

  for i := 0 to (FWidth * FHeight) - 1 do
  begin
    ptrR^ := ptr^.R;
    ptrG^ := ptr^.G;
    ptrB^ := ptr^.B;

    Inc(ptr);
    Inc(ptrR);
    Inc(ptrG);
    Inc(ptrB);
  end;

  imgGaussBlur(Radius, r,g,b, FWidth, FHeight);

  ptr := Result.FData;
  ptrR := @r[0];
  ptrG := @g[0];
  ptrB := @b[0];

  for i := 0 to (FWidth * FHeight) - 1 do
  begin
    ptr^.R := ptrR^;
    ptr^.G := ptrG^;
    ptr^.B := ptrB^;

    Inc(ptr);
    Inc(ptrR);
    Inc(ptrG);
    Inc(ptrB);
  end;
end;

function TSimbaImage.Blend(Points: TPointArray; Radius: Integer): TSimbaImage;
var
  P: TPoint;
  X, Y, Count: Integer;
  Area: TBox;
  R, G, B: Int64;
  Color: TColorBGRA;
begin
  Result := TSimbaImage.Create(Width, Height);

  for P in Points do
  begin
    Area.X1 := Max(P.X - Radius, 0);
    Area.Y1 := Max(P.Y - Radius, 0);
    Area.X2 := Min(P.X + Radius, FWidth-1);
    Area.Y2 := Min(P.Y + Radius, FHeight-1);

    Count := 0;

    R := 0;
    G := 0;
    B := 0;

    for X := Area.X1 to Area.X2 do
      for Y := Area.Y1 to Area.Y2 do
      begin
        Color := FData[Y * FWidth + X];
        if FTransparentColorActive and Color.EqualsIgnoreAlpha(FTransparentRGB) then
          Continue;

        Inc(R, Color.R);
        Inc(G, Color.G);
        Inc(B, Color.B);

        Inc(Count);
      end;

    if (Count > 0) then
    begin
      Color.R := R div Count;
      Color.G := G div Count;
      Color.B := B div Count;

      Result.FData[P.Y * FWidth + P.X] := Color;
    end;
  end;
end;

function TSimbaImage.Downsample(Scale: Integer): TSimbaImage;
var
  Area: Double;

  function BlendArea(const X1, Y1, X2, Y2: Integer): TColorBGRA; inline;
  var
    R, G, B: Integer;
    Hit, Miss: Integer;
    X, Y: Integer;
    Color: TColorBGRA;
  begin
    Miss := 0;
    Hit := 0;

    R := 0;
    G := 0;
    B := 0;

    for X := X1 to X2 do
      for Y := Y1 to Y2 do
      begin
        Color := FData[Y * FWidth + X];

        if FTransparentColorActive and Color.EqualsIgnoreAlpha(FTransparentRGB) then
          Inc(Miss)
        else
        begin
          Inc(Hit);

          Inc(R, Color.R);
          Inc(G, Color.G);
          Inc(B, Color.B);
        end;
      end;

    Result.R := Round((R + (R div Hit) * Miss) * Area);
    Result.G := Round((G + (G div Hit) * Miss) * Area);
    Result.B := Round((B + (B div Hit) * Miss) * Area);
    Result.A := 0;
  end;

var
  X, Y, W, H: Integer;
  OldX, OldY: Integer;
  Color: TColorBGRA;
begin
  Result := TSimbaImage.Create(FWidth div Scale, FHeight div Scale);

  Area := Double(1.0) / Sqr(Scale);

  W := Result.Width - 1;
  H := Result.Height - 1;

  for Y := 0 to H do
    for X := 0 to W do
    begin
      OldX := X * Scale;
      OldY := Y * Scale;

      Color := FData[OldY * FWidth + OldX];
      if FTransparentColorActive and Color.EqualsIgnoreAlpha(FTransparentRGB) then
        Continue;

      Result.Data[Y * Result.Width + X] := BlendArea(OldX, OldY, (OldX + Scale) - 1, (OldY + Scale) - 1);
    end;
end;

function TSimbaImage.GetCenter: TPoint;
begin
  Result.X := FWidth div 2;
  Result.Y := FHeight div 2;
end;

function TSimbaImage.GetFontAntialiasing: Boolean;
begin
  Result := FTextDrawer.Antialiased;
end;

function TSimbaImage.GetFontName: String;
begin
  Result := FTextDrawer.FontName;
end;

class function TSimbaImage.LoadedFontNames: TStringArray;
begin
  Result := SimbaFreeTypeFontLoader.FontNames;
end;

function TSimbaImage.GetFontSize: Single;
begin
  Result := FTextDrawer.Size;
end;

function TSimbaImage.GetFontBold: Boolean;
begin
  Result := FTextDrawer.Bold;
end;

function TSimbaImage.GetFontItalic: Boolean;
begin
  Result := FTextDrawer.Italic;
end;

procedure TSimbaImage.SetFontAntialiasing(Value: Boolean);
begin
  FTextDrawer.Antialiased := Value;
end;

procedure TSimbaImage.SetFontName(Value: String);
begin
  FTextDrawer.FontName := Value;
end;

procedure TSimbaImage.SetFontSize(Value: Single);
begin
  FTextDrawer.Size := Value;
end;

procedure TSimbaImage.SetFontBold(Value: Boolean);
begin
  FTextDrawer.Bold := Value;
end;

procedure TSimbaImage.SetFontItalic(Value: Boolean);
begin
  FTextDrawer.Italic := Value;
end;

function TSimbaImage.TextWidth(Text: String): Integer;
begin
  Result := FTextDrawer.TextWidth(Text);
end;

function TSimbaImage.TextHeight(Text: String): Integer;
begin
  Result := FTextDrawer.TextHeight(Text);
end;

function TSimbaImage.TextSize(Text: String): TPoint;
begin
  Result := FTextDrawer.TextSize(Text);
end;

procedure TSimbaImage.DrawText(Text: String; Position: TPoint; Color: TColor);
begin
  FTextDrawer.DrawText(Text, Position, Color);
end;

procedure TSimbaImage.DrawText(Text: String; Box: TBox; ACenter: Boolean; Color: TColor);
begin
  FTextDrawer.DrawText(Text, Box, ACenter, Color);
end;

procedure TSimbaImage.DrawTextLines(Text: TStringArray; Position: TPoint; Color: TColor);
var
  I, LineHeight: Integer;
begin
  LineHeight := TextHeight('TaylorSwift') + 1;

  for I := 0 to High(Text) do
  begin
    DrawText(Text[I], Position, Color);

    Inc(Position.Y, LineHeight);
    if (Position.Y >= FHeight) then
      Break;
  end;
end;

procedure TSimbaImage.SetSize(NewWidth, NewHeight: Integer);
var
  NewData: PColorBGRA;
  I, MinW, MinH: Integer;
  Size: SizeInt;
begin
  if (not FDataOwner) then
    SimbaException('TSimbaImage.SetSize: Cannot resize a image with external memory');

  if (NewWidth <> FWidth) or (NewHeight <> FHeight) then
  begin
    if (NewWidth * NewHeight <> 0) then
      NewData := AllocMem(NewWidth * NewHeight * SizeOf(TColorBGRA))
    else
      NewData := nil;

    if Assigned(FData) and Assigned(NewData) and (FWidth * FHeight <> 0) then
    begin
      MinW := Min(NewWidth, FWidth);
      MinH := Min(NewHeight, FHeight);

      Size := MinW * SizeOf(TColorBGRA);
      for I := 0 to MinH - 1 do
        Move(FData[I * FWidth], NewData[I * NewWidth], Size);
    end;
    if Assigned(FData) then
      FreeMem(FData);

    FData := NewData;
    FWidth := NewWidth;
    FHeight := NewHeight;
  end;
end;

function TSimbaImage.ResizeNN(NewWidth, NewHeight: Integer): TSimbaImage;
var
  X, Y, W, H: Integer;
begin
  Result := TSimbaImage.Create(NewWidth, NewHeight);

  W := NewWidth - 1;
  H := NewHeight - 1;

  for Y := 0 to H do
    for X := 0 to W do
      Result.Data[Y * NewWidth + X] := FData[((Y * FHeight) div NewHeight) * FWidth + (X * FWidth) div NewWidth];
end;

function TSimbaImage.ResizeBilinear(NewWidth, NewHeight: Integer): TSimbaImage;
var
  X, Y, OldX, OldY: Integer;
  p0, p1, p2, p3: TColorBGRA;
  RatioX, RatioY, dX, dY: Single;
  SrcRows: TSimbaImageRowPtrs;
  Color: TColorBGRA;
  W,H: Integer;
begin
  Result := TSimbaImage.Create(NewWidth, NewHeight);

  SrcRows := RowPtrs;

  RatioX := (FWidth - 1) / NewWidth;
  RatioY := (FHeight - 1) / NewHeight;

  W := NewWidth - 1;
  H := NewHeight - 1;
  for Y := 0 to H do
    for X := 0 to W do
    begin
      OldX := Trunc(RatioX * X);
      OldY := Trunc(RatioY * Y);

      p0 := SrcRows[OldY,     OldX    ];
      p1 := SrcRows[OldY,     OldX + 1];
      p2 := SrcRows[OldY + 1, OldX    ];
      p3 := SrcRows[OldY + 1, OldX + 1];

      dX := ratioX * X - OldX;
      dY := ratioY * Y - OldY;

      Color.R := Trunc(
        p0.R * (1-dX) * (1-dY) +
        p1.R * (dX * (1-dY)) +
        p2.R * (dY * (1-dX)) +
        p3.R * (dX * dY)
      );

      Color.G := Trunc(
        p0.G * (1-dX) * (1-dY) +
        p1.G * (dX * (1-dY)) +
        p2.G * (dY * (1-dX)) +
        p3.G * (dX * dY)
      );

      Color.B := Trunc(
        p0.B * (1-dX) * (1-dY) +
        p1.B * (dX * (1-dY)) +
        p2.B * (dY * (1-dX)) +
        p3.B * (dX * dY)
      );

      Result.Data[Y * NewWidth + X] := Color;
    end;
end;

function TSimbaImage.GetPixels(Points: TPointArray): TColorArray;
var
  I: Integer;
begin
  SetLength(Result, Length(Points));
  for I := 0 to High(Points) do
    with Points[I] do
    begin
      AssertInImage('GetPixels', X, Y);

      Result[I] := FData[Y * FWidth + X].ToColor();
    end;
end;

procedure TSimbaImage.SetPixels(Points: TPointArray; Colors: TColorArray);
var
  I: Integer;
begin
  if (Length(Points) <> Length(Colors)) then
    SimbaException('TSimbaImage.SetPixels: Pixel & Color arrays must be same lengths (%d, %s)', [Length(Points), Length(Colors)]);

  for I := 0 to High(Points) do
    with Points[I] do
    begin
      AssertInImage('SetPixels', X, Y);

      FData[Y * FWidth + X] := Colors[I].ToBGRA();
    end;
end;

procedure TSimbaImage.SetExternalData(AData: PColorBGRA; AWidth, AHeight: Integer);
begin
  SetSize(0, 0);

  FWidth := AWidth;
  FHeight := AHeight;
  FData := AData;
  FDataOwner := False;
end;

procedure TSimbaImage.ResetExternalData;
begin
  if FDataOwner then
    Exit;

  FDataOwner := True;
  FData := nil;

  SetSize(0, 0);
end;

function TSimbaImage.ThresholdAdaptive(Alpha, Beta: Byte; AInvert: Boolean; Method: ESimbaImageThreshMethod; K: Integer): TSimbaImage;
var
  I: Integer;
  vMin, vMax, Threshold: UInt8;
  Counter: Int64;
  Tab: array[0..256] of UInt8;
  Upper: PtrUInt;
  SrcPtr, DestPtr: PColorBGRA;
begin
  Result := TSimbaImage.Create(FWidth, FHeight);

  if Alpha = Beta then Exit;
  if Alpha > Beta then Swap(Alpha, Beta);

  //Finding the threshold - While at it convert image to grayscale.
  Threshold := 0;
  case Method of
    //Find the Arithmetic Mean / Average.
    ESimbaImageThreshMethod.MEAN:
      begin
        SrcPtr := FData;
        DestPtr := Result.Data;
        Upper := PtrUInt(@FData[FWidth * FHeight]);

        Counter := 0;

        while (PtrUInt(SrcPtr) < Upper) do
        begin
          DestPtr^.R := (SrcPtr^.B + SrcPtr^.G + SrcPtr^.R) div 3;

          Counter += DestPtr^.R;

          Inc(SrcPtr);
          Inc(DestPtr);
        end;

        Threshold := (Counter div ((FWidth * FHeight) - 1)) + K;
      end;

    //Middle of Min- and Max-value
    ESimbaImageThreshMethod.MIN_MAX:
      begin
        vMin := 255;
        vMax := 0;

        SrcPtr := FData;
        DestPtr := Result.Data;
        Upper := PtrUInt(@FData[FWidth * FHeight]);

        while (PtrUInt(SrcPtr) < Upper) do
        begin
          DestPtr^.R := (SrcPtr^.B + SrcPtr^.G + SrcPtr^.R) div 3;

          if (DestPtr^.R < vMin) then vMin := DestPtr^.R else
          if (DestPtr^.R > vMax) then vMax := DestPtr^.R;

          Inc(SrcPtr);
          Inc(DestPtr)
        end;

        Threshold := ((vMax + Integer(vMin)) shr 1) + K;
      end;
  end;

  if AInvert then Swap(Alpha, Beta);
  for I:=0 to Threshold - 1 do Tab[I] := Alpha;
  for I:=Threshold to 255   do Tab[I] := Beta;

  Upper := PtrUInt(@Result.Data[Result.Width * Result.Height]);
  DestPtr := Result.Data;
  while (PtrUInt(DestPtr) < Upper) do
  begin
    DestPtr^.R := Tab[DestPtr^.R];

    Inc(DestPtr);
  end;
end;

{
  Radius = Window size
  Invert = Invert output
  R      = dynamic range of standard deviation (default = 128)
  K      = constant value in range 0.2..0.5 (default = 0.5)
}
function TSimbaImage.ThresholdSauvola(Radius: Integer; AInvert: Boolean; R: Single; K: Single): TSimbaImage;
var
  Mat: TByteMatrix;
  Integral: TSimbaIntegralImageF;
  X,Y,W,H: Integer;
  Left, Right, Top, Bottom: Integer;
  Count: Integer;
  Sum, SumSquares: Double;
  Mean, Stdev, Threshold: Double;
  HitColor, MissColor: TColorBGRA;
begin
  Result := TSimbaImage.Create(FWidth, FHeight);

  Mat := Self.ToGreyMatrix();
  Mat.GetSize(W, H);

  Dec(W);
  Dec(H);

  Radius := (Radius - 1) div 2;
  Integral := TSimbaIntegralImageF.Create(Mat);

  HitColor.AsInteger := $FFFFFF;
  MissColor.AsInteger := 0;
  if AInvert then
    Swap(HitColor, MissColor);

  for Y := 0 to H do
    for X := 0 to W do
    begin
      Left   := Max(X-Radius, 0);
      Right  := Min(X+Radius, W);
      Top    := Max(Y-Radius, 0);
      Bottom := Min(Y+Radius, H);

      //Sum := 0;
      //SumSquares := 0;
      //
      //for y := top to bottom do
      //  for x := left to right do
      //  begin
      //    Sum += mat[y,x];
      //    SumSquares += mat[y,x]*mat[y,x];
      //  end;

      Integral.Query(Left, Top, Right, Bottom, Sum, SumSquares);

      Count := (Bottom - Top + 1) * (Right - Left + 1);
      Mean := Sum / Count;
      Stdev := Sqrt((SumSquares / Count) - Sqr(Mean));
      Threshold := Mean * (1.0 + K * ((Stdev / R) - 1.0));

      if Mat[Y, X] < Threshold then
        Result.FData[Y * FWidth + X] := MissColor
      else
        Result.FData[Y * FWidth + X] := HitColor;
    end;
end;

procedure TSimbaImage.Pad(Amount: Integer);
var
  OldWidth, OldHeight: Integer;
  Y: Integer;
begin
  OldWidth := FWidth;
  OldHeight := FHeight;

  SetSize(FWidth + (Amount * 2), FHeight + (Amount * 2));

  for Y := OldHeight downto 0 do
  begin
    Move(FData[Y * FWidth], FData[(Y + Amount) * FWidth + Amount], OldWidth * SizeOf(TColorBGRA));

    // clear old pixels
    if (Y < Amount) then
      FillData(@FData[Y * FWidth], OldWidth * SizeOf(TColorBGRA), TransparentRGB)
    else
      FillData(@FData[Y * FWidth], Amount * SizeOf(TColorBGRA), TransparentRGB);
  end;
end;

procedure TSimbaImage._DrawTPA(const TPA: TPointArray; Color: TColor);
var
  BGRA: TColorBGRA;
  Point: TPoint;
begin
  BGRA := Color.ToBGRA();

  for Point in TPA do
    if (Point.X >= 0) and (Point.Y >= 0) and (Point.X < FWidth) and (Point.Y < FHeight) then
      FData[Point.Y * FWidth + Point.X] := BGRA;
end;

procedure TSimbaImage._DrawTPAAlpha(const TPA: TPointArray; Color: TColor; Alpha: Byte);
var
  R,G,B,A: Byte;
  Point: TPoint;
  Ptr: PColorBGRA;
begin
  R := (Color.R * (255 - Alpha + 1)) shr 8;
  G := (Color.G * (255 - Alpha + 1)) shr 8;
  B := (Color.B * (255 - Alpha + 1)) shr 8;
  A := Alpha + 1;

  for Point in TPA do
    if (Point.X >= 0) and (Point.Y >= 0) and (Point.X < FWidth) and (Point.Y < FHeight) then
    begin
      Ptr := @FData[Point.Y * FWidth + Point.X];
      Ptr^.R := R + Ptr^.R * A shr 8;
      Ptr^.G := G + Ptr^.G * A shr 8;
      Ptr^.B := B + Ptr^.B * A shr 8;
      Ptr^.A := Alpha;
    end;
end;

procedure TSimbaImage._DrawBoxFilled(Box: TBox; Color: TColor);
var
  BGRA: TColorBGRA;
  Size: Integer;

  procedure _Row(const Y: Integer; X1, X2: Integer); inline;
  begin
    FillData(@FData[Y * FWidth + X1], Size, BGRA);
  end;

  {$i boxfilled.inc}

begin
  BGRA := Color.ToBGRA();
  Size := (Box.X2 - Box.X1) + 1;

  _BoxFilled(Box);
end;

procedure TSimbaImage._DrawBoxFilledAlpha(Box: TBox; Color: TColor; Alpha: Byte);
var
  R,G,B,A: Byte;
  Size: Integer;

  procedure _Row(const Y: Integer; X1, X2: Integer); inline;
  var
    Ptr: PColorBGRA;
    Upper: PtrUInt;
  begin
    Ptr := @FData[Y * FWidth + X1];
    Upper := PtrUInt(Ptr) + Size;

    while (PtrUInt(Ptr) <= Upper) do
    begin
      Ptr^.R := R + Ptr^.R * A shr 8;
      Ptr^.G := G + Ptr^.G * A shr 8;
      Ptr^.B := B + Ptr^.B * A shr 8;
      Ptr^.A := Alpha;

      Inc(Ptr);
    end;
  end;

  {$i boxfilled.inc}

begin
  R := (Color.R * (255 - Alpha + 1)) shr 8;
  G := (Color.G * (255 - Alpha + 1)) shr 8;
  B := (Color.B * (255 - Alpha + 1)) shr 8;
  A := Alpha + 1;

  Size := (Box.X2 - Box.X1) * SizeOf(TColorBGRA);

  _BoxFilled(Box);
end;

procedure TSimbaImage._DrawCircleFilledAlpha(ACenter: TPoint; Radius: Integer; Color: TColor; Alpha: Byte);
var
  R,G,B,A: Byte;

  procedure _Row(const Y: Integer; X1, X2: Integer); inline;
  var
    Ptr: PColorBGRA;
    Upper: PtrUInt;
  begin
    if (Y >= 0) and (Y < FHeight) then
    begin
      X1 := EnsureRange(X1, 0, FWidth - 1);
      X2 := EnsureRange(X2, 0, FWidth - 1);

      if ((X2 - X1) + 1 > 0) then
      begin
        Ptr := @FData[Y * FWidth + X1];
        Upper := PtrUInt(Ptr) + ((X2 - X1) * SizeOf(TColorBGRA));

        while PtrUInt(Ptr) <= Upper do
        begin
          Ptr^.R := R + Ptr^.R * A shr 8;
          Ptr^.G := G + Ptr^.G * A shr 8;
          Ptr^.B := B + Ptr^.B * A shr 8;
          Ptr^.A := Alpha;

          Inc(Ptr);
        end;
      end;
    end;
  end;

  {$i circlefilled.inc}

begin
  R := (Color.R * (255 - Alpha + 1)) shr 8;
  G := (Color.G * (255 - Alpha + 1)) shr 8;
  B := (Color.B * (255 - Alpha + 1)) shr 8;
  A := Alpha + 1;

  _CircleFilled(ACenter.X, ACenter.Y, Radius);
end;

procedure TSimbaImage._DrawCircleFilled(ACenter: TPoint; Radius: Integer; Color: TColor);
var
  BGRA: TColorBGRA;

  procedure _Row(const Y: Integer; X1, X2: Integer); inline;
  begin
    if (Y >= 0) and (Y < FHeight) then
    begin
      X1 := EnsureRange(X1, 0, FWidth - 1);
      X2 := EnsureRange(X2, 0, FWidth - 1);
      if ((X2 - X1) + 1 > 0) then
        FillData(@FData[Y * FWidth + X1], (X2 - X1) + 1, BGRA);
    end;
  end;

  {$i circlefilled.inc}

begin
  BGRA := Color.ToBGRA(); // rgb to bgra

  _CircleFilled(ACenter.X, ACenter.Y, Radius);
end;

procedure TSimbaImage._DrawPolygonFilledAlpha(Points: TPointArray; Color: TColor; Alpha: Byte);
var
  R,G,B,A: Byte;

  procedure _Row(const Y: Integer; X1, X2: Integer); inline;
  var
    Ptr: PColorBGRA;
    Upper: PtrUInt;
  begin
    // Y is already clipped in _PolygonFilled
    X1 := EnsureRange(X1, 0, FWidth - 1);
    X2 := EnsureRange(X2, 0, FWidth - 1);

    if ((X2 - X1) + 1 > 0) then
    begin
      Ptr := @FData[Y * FWidth + X1];
      Upper := PtrUInt(Ptr) + ((X2 - X1) * SizeOf(TColorBGRA));

      while PtrUInt(Ptr) <= Upper do
      begin
        Ptr^.R := R + Ptr^.R * A shr 8;
        Ptr^.G := G + Ptr^.G * A shr 8;
        Ptr^.B := B + Ptr^.B * A shr 8;
        Ptr^.A := Alpha;

        Inc(Ptr);
      end;
    end;
  end;

  {$i polygonfilled.inc}

begin
  R := (Color.R * (255 - Alpha + 1)) shr 8;
  G := (Color.G * (255 - Alpha + 1)) shr 8;
  B := (Color.B * (255 - Alpha + 1)) shr 8;
  A := Alpha + 1;

  _PolygonFilled(Points, TRect.Create(0,0,FWidth-1,FHeight-1));
end;

procedure TSimbaImage._DrawPolygonFilled(Points: TPointArray; Color: TColor);
var
  BGRA: TColorBGRA;

  procedure _Row(const Y: Integer; X1, X2: Integer); inline;
  begin
    // Y is already clipped in _PolygonFilled
    X1 := EnsureRange(X1, 0, FWidth - 1);
    X2 := EnsureRange(X2, 0, FWidth - 1);

    if ((X2 - X1) + 1 > 0) then
      FillData(@FData[Y * FWidth + X1], (X2 - X1) + 1, BGRA);
  end;

  {$i polygonfilled.inc}

begin
  BGRA := Color.ToBGRA();

  _PolygonFilled(Points, TRect.Create(0,0,FWidth-1,FHeight-1));
end;

procedure TSimbaImage.NotifyUnfreed;
begin
  inherited NotifyUnfreed();

  if (SaveUnfreedImages <> '') then
  try
    SaveToFile(IncludeTrailingPathDelimiter(SetDirSeparators(SaveUnfreedImages)) + IntToStr(PtrUInt(Self)) + '.bmp');
  except
    on E: Exception do
      DebugLn(E.ToString);
  end;
end;

function TSimbaImage.GetPixel(X, Y: Integer): TColor;
begin
  AssertInImage('GetPixel', X, Y);

  with FData[Y * FWidth + X] do
    Result := R or G shl G_BIT or B shl B_BIT;
end;

procedure TSimbaImage.SetPixel(X, Y: Integer; Color: TColor);
begin
  AssertInImage('SetPixel', X, Y);

  FData[Y * FWidth + X] := Color.ToBGRA();
end;

procedure TSimbaImage.SetTransparentColor(Value: TColor);
begin
  FTransparentColor := Value;
  FTransparentRGB := Value.ToBGRA();
end;

function TSimbaImage.InImage(const X, Y: Integer): Boolean;
begin
  Result := (X >= 0) and (Y >= 0) and (X < FWidth) and (Y < FHeight);
end;

procedure TSimbaImage.AssertInImage(const Method: String; const X, Y: Integer);
begin
  if (X < 0) or (Y < 0) or (X >= FWidth) or (Y >= FHeight) then
    SimbaException('TSimbaImage.%s: %d,%d is outside the image bounds: %d,%d,%d,%d', [Method, X, Y, 0,0,FWidth-1,FHeight-1]);
end;

function TSimbaImage.MatchTemplate(Template: TSimbaImage; Formula: ETMFormula): TSingleMatrix;
begin
  Result := simba.matchtemplate.MatchTemplate(Self.ToMatrixBGR(), Template.ToMatrixBGR(), Formula);
end;

function TSimbaImage.MatchTemplateMask(Template: TSimbaImage; Formula: ETMFormula): TSingleMatrix;
begin
  Result := simba.matchtemplate.MatchTemplateMask(Self.ToMatrixBGR(), Template.ToMatrixBGR(), Formula);
end;

procedure TSimbaImage.DrawLineAA(Start, Stop: TPoint; Color: TColor; Thickness: Single);

  procedure DoClearAlpha;
    {$i clearpixelalpha.inc}
    {$i lineantialias.inc}
  begin
    _LineAntialias(
      Start.X, Start.Y,
      Stop.X, Stop.Y,
      Thickness
    );
  end;

  procedure DoDraw;
  var
    BGRA: TColorBGRA;

    {$i setpixelantialias.inc}
    {$i lineantialias.inc}
  begin
    BGRA := Color.ToBGRA();

    _LineAntialias(
      Start.X, Start.Y,
      Stop.X, Stop.Y,
      Thickness
    );
  end;

begin
  DoClearAlpha();
  DoDraw();
end;

procedure TSimbaImage.DrawEllipseAA(ACenter: TPoint; XRadius, YRadius: Integer; Color: TColor; Thickness: Single);

  procedure DoClearAlpha;
    {$i clearpixelalpha.inc}
    {$i ellipseantialias.inc}
  begin
    _EllipseAntialias(
      ACenter.X - XRadius, ACenter.Y - YRadius,
      ACenter.X + XRadius, ACenter.Y + YRadius,
      Thickness
    );
  end;

  procedure DoDraw;
  var
    BGRA: TColorBGRA;

    {$i setpixelantialias.inc}
    {$i ellipseantialias.inc}
  begin
    BGRA := Color.ToBGRA();

    _EllipseAntialias(
      ACenter.X - XRadius, ACenter.Y - YRadius,
      ACenter.X + XRadius, ACenter.Y + YRadius,
      Thickness
    );
  end;

begin
  DoClearAlpha();
  DoDraw();
end;

procedure TSimbaImage.DrawCircleAA(ACenter: TPoint; Radius: Integer; Color: TColor; Thickness: Single);
begin
  DrawEllipseAA(ACenter, Radius, Radius, Color, Thickness);
end;

constructor TSimbaImage.Create;
begin
  inherited Create();

  FDataOwner := True;
  FTextDrawer := TSimbaTextDrawer.Create(Self);

  TransparentColorActive := True;
  TransparentColor := 0;
end;

constructor TSimbaImage.Create(AWidth, AHeight: Integer);
begin
  Create();

  SetSize(AWidth, AHeight);
end;

constructor TSimbaImage.CreateFromFile(FileName: String);
begin
  Create();

  LoadFromFile(FileName);
end;

constructor TSimbaImage.CreateFromZip(ZipFileName, ZipEntryName: String);
var
  Stream: TMemoryStream;
begin
  Create();

  if ZipExtractOne(ZipFileName, ZipEntryName, Stream) then
  try
    LoadFromStream(Stream, ZipEntryName);
  finally
    Stream.Free();
  end;
end;

constructor TSimbaImage.CreateFromString(Str: String);
begin
  Create();

  LoadFromString(Str);
end;

constructor TSimbaImage.CreateFromData(AWidth, AHeight: Integer; AData: PColorBGRA; ADataWidth: Integer);
begin
  Create();

  LoadFromData(AWidth, AHeight, AData, ADataWidth);
end;

constructor TSimbaImage.CreateFromWindow(Window: TWindowHandle);
var
  B: TBox;
  ImageData: PColorBGRA = nil;
begin
  Create();

  if SimbaNativeInterface.GetWindowBounds(Window, B) and
     SimbaNativeInterface.GetWindowImage(Window, 0, 0, B.Width - 1, B.Height - 1, ImageData) then
  try
    LoadFromData(B.Width - 1, B.Height - 1, ImageData, B.Width - 1);
  finally
    FreeMem(ImageData);
  end;
end;

destructor TSimbaImage.Destroy;
begin
  if FDataOwner then
    SetSize(0, 0);

  if (FTextDrawer <> nil) then
    FreeAndNil(FTextDrawer);

  inherited Destroy();
end;

end.

