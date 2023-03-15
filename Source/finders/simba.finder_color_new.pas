{
  Author: Raymond van Venetië and Merlijn Wajer
  Project: Simba (https://github.com/MerlijnWajer/Simba)
  License: GNU General Public License (https://www.gnu.org/licenses/gpl-3.0)

  The colorfinder.

  Lots of code from: https://github.com/slackydev/colorlib
}
unit simba.finder_color_new;

{$DEFINE SIMBA_MAX_OPTIMIZATION}
{$i simba.inc}

interface

uses
  Classes, SysUtils, Math, Graphics,
  simba.mufasatypes, simba.colormath_conversion, simba.colormath_distance;

type
  TColorDistanceFunc = function(const Color1: Pointer; const Color2: TColorBGRA; const mul: TChannelMultipliers): Single;

  TColorFinder = record
  private
    FCompareFunc: TColorDistanceFunc;
    FColorContainer: array[0..2] of Single;
    FColor: Pointer;
    FTolerance: Single;
    FMultipliers: TChannelMultipliers;
    FMaxDistance: Single;
  public
    procedure Setup(Formula: EColorSpace; Color: TColor; Tolerance: Single; Multiplier: TChannelMultipliers);

    function Find(Buffer: PColorBGRA; BufferWidth: Integer; SearchWidth, SearchHeight: Integer; Offset: TPoint; MaxToFind: Integer = -1): TPointArray;
    function Match(Buffer: PColorBGRA; BufferWidth: Integer; SearchWidth, SearchHeight: Integer): TSingleMatrix;
  end;

implementation

uses
  simba.overallocatearray;

procedure TColorFinder.Setup(Formula: EColorSpace; Color: TColor; Tolerance: Single; Multiplier: TChannelMultipliers);
begin
  FColor := @FColorContainer[0];

  FTolerance := Tolerance;
  FMultipliers := Multiplier;

  case Formula of
    EColorSpace.RGB:
      begin
        FCompareFunc := TColorDistanceFunc(@_DistanceRGB);
        FMaxDistance := DistanceRGB_Max(Multiplier);
        PColorRGB(FColor)^ := Color.ToRGB();
      end;

    EColorSpace.HSV:
      begin
        FCompareFunc := TColorDistanceFunc(@_DistanceHSV);
        FMaxDistance := DistanceHSV_Max(Multiplier);
        PColorHSV(FColor)^ := Color.ToHSV();
      end;

    EColorSpace.HSL:
      begin
        FCompareFunc := TColorDistanceFunc(@_DistanceHSL);
        FMaxDistance := DistanceHSL_Max(Multiplier);
        PColorHSL(FColor)^ := Color.ToHSL();
      end;

    EColorSpace.XYZ:
      begin
        FCompareFunc := TColorDistanceFunc(@_DistanceXYZ);
        FMaxDistance := DistanceXYZ_Max(Multiplier);
        PColorXYZ(FColor)^ := Color.ToXYZ();
      end;

    EColorSpace.LAB:
      begin
        FCompareFunc := TColorDistanceFunc(@_DistanceLAB);
        FMaxDistance := DistanceLAB_Max(Multiplier);
        PColorLAB(FColor)^ := Color.ToLAB();
      end;

    EColorSpace.LCH:
      begin
        FCompareFunc := TColorDistanceFunc(@_DistanceLCH);
        FMaxDistance := DistanceLCH_Max(Multiplier);
        PColorLCH(FColor)^ := Color.ToLCH();
      end;

    EColorSpace.DeltaE:
      begin
        FCompareFunc := TColorDistanceFunc(@_DistanceDeltaE);
        FMaxDistance := DistanceDeltaE_Max(Multiplier);
        PColorLAB(FColor)^ := Color.ToLAB();
      end;
  end;
end;

function TColorFinder.Find(Buffer: PColorBGRA; BufferWidth: Integer; SearchWidth, SearchHeight: Integer; Offset: TPoint; MaxToFind: Integer): TPointArray;
var
  X, Y, RowSize: Integer;
  RowPtr, Ptr: PByte;
  PointBuffer: TSimbaPointBuffer;
label
  Finished;
begin
  Result := nil;
  if IsZero(FMaxDistance) then
    Exit;
  if (SearchWidth <= 0) or (SearchHeight <= 0) or (Buffer = nil) or (BufferWidth <= 0) then
    Exit;

  RowSize := BufferWidth * SizeOf(TRGB32);
  RowPtr := PByte(Buffer);

  Dec(SearchHeight);
  Dec(SearchWidth);
  for Y := 0 to SearchHeight do
  begin
    Ptr := RowPtr;
    for X := 0 to SearchWidth do
    begin
      if (Self.FCompareFunc(FColor, PColorBGRA(Ptr)^, FMultipliers) / FMaxDistance * 100 <= FTolerance) then
      begin
        PointBuffer.Add(X + Offset.X, Y + Offset.Y);
        if (PointBuffer.Count = MaxToFind) then
          goto Finished;
      end;

      Inc(Ptr, SizeOf(TRGB32));
    end;

    Inc(RowPtr, RowSize);
  end;
  Finished:

  Result := PointBuffer.Trim();
end;

function TColorFinder.Match(Buffer: PColorBGRA; BufferWidth: Integer; SearchWidth, SearchHeight: Integer): TSingleMatrix;
var
  X, Y, RowSize: Integer;
  RowPtr, Ptr: PByte;
begin
  Result := nil;
  if IsZero(FMaxDistance) then
    Exit;
  if (SearchWidth <= 0) or (SearchHeight <= 0) or (Buffer = nil) or (BufferWidth <= 0) then
    Exit;

  Result.SetSize(SearchWidth, SearchHeight);

  RowSize := BufferWidth * SizeOf(TRGB32);
  RowPtr := PByte(Buffer);

  Dec(SearchHeight);
  Dec(SearchWidth);
  for Y := 0 to SearchHeight do
  begin
    Ptr := RowPtr;
    for X := 0 to SearchWidth do
    begin
      Result[Y, X] := 1 - (FCompareFunc(FColor, PColorBGRA(Ptr)^, FMultipliers) / FMaxDistance);

      Inc(Ptr, SizeOf(TRGB32));
    end;

    Inc(RowPtr, RowSize);
  end;
end;

end.

