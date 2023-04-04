unit ChakraAudioUtils;

{$mode delphi}

interface

  uses
    ChakraTypes, ChakraAudioTypes;

  function GetChannelSpectrum(aChannel: Integer; aSpectrumType: TAudioSpectrumType; aSpectrumHeight, aSpectrumWidth: Integer): TJsValue;

implementation

  uses
    Chakra, ChakraUtils, Bass;

  function GetWaveformSpectrum(aChannel, aHeight, aWidth: Integer): TJsValue;
  begin
    Result := Undefined;
  end;

  function GetFFTSpectrum(aChannel: Integer; aSpectrumType: TAudioSpectrumType; aHeight, aWidth: Integer): TJsValue;
  begin
    Result := Undefined;
  end;

  function GetChannelSpectrum;
  begin
    Result := Undefined;

    if BASS_SetDevice(aChannel) then begin
      if aSpectrumType = asWaveform then begin
        Result := GetWaveformSpectrum(aChannel, aSpectrumHeight, aSpectrumWidth);
      end else begin
        Result := GetFFTSpectrum(aChannel, aSpectrumType, aSpectrumHeight, aSpectrumWidth);
      end;
    end;
  end;

end.