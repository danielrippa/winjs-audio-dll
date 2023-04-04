unit ChakraAudioUtils;

{$mode delphi}

interface

  uses
    ChakraTypes, ChakraAudioTypes;

  function GetChannelSpectrum(aChannel: Integer; aSpectrumType: TAudioSpectrumType; aSpectrumHeight, aSpectrumWidth: Integer): TJsValue;

implementation

  uses
    Chakra, ChakraUtils, Bass;

  type

    TSingleArray = Array of Single;

  function GetWaveformSpectrum(aChannel, aHeight, aWidth: Integer): TJsValue;
  var
    SpectrumData: TSingleArray;
    info: BASS_CHANNELINFO;
    ChannelsCount: Integer;
    Ch: Integer;
    Channel: TJsValue;
    SpectrumValue: Single;
    L: Integer;
    X, Y, Z: Integer;
    I: Integer;
  begin

    BASS_ChannelGetInfo(aChannel, info);
    ChannelsCount := info.chans;

    L := ChannelsCount * aWidth;

    SetLength(SpectrumData, L);
    BASS_CHannelGetData(aChannel, SpectrumData, (L * SizeOf(Single)) or BASS_DATA_FLOAT);

    Result := CreateArray(ChannelsCount);

    for Ch := 0 to ChannelsCount - 1 do begin

      Channel := CreateArray(aWidth);
      SetArrayItem(Result, Ch, Channel);

      for X := 0 to aWidth - 1 do begin

        SpectrumValue := SpectrumData[ X * ChannelsCount + Ch ];

        Y := Trunc(SpectrumValue * 10);

        SetArrayItem(Channel, X, IntAsJsNumber(Y));

      end;

    end;

  end;

  function GetFFTSpectrum(aChannel: Integer; aSpectrumType: TAudioSpectrumType; aHeight, aWidth: Integer): TJsValue;
  begin
    Result := Undefined;
  end;

  function GetChannelSpectrum;
  begin
    Result := Undefined;

    if aSpectrumType = asWaveform then begin
      Result := GetWaveformSpectrum(aChannel, aSpectrumHeight, aSpectrumWidth);
    end else begin
      Result := GetFFTSpectrum(aChannel, aSpectrumType, aSpectrumHeight, aSpectrumWidth);
    end;

  end;

end.