unit ChakraAudio;

{$mode delphi}

interface

  uses
    ChakraTypes;

  function GetJsValue: TJsValue;

implementation

  uses
    Chakra, ChakraUtils, Win32AudioDevices, Win32AudioVolume, ChakraErr, SysUtils, Bass, Bass_Fx, ChakraAudioTypes, ChakraAudioUtils;

  function ChakraGetMasterVolume(Args: PJsValue; ArgCount: Word): TJsValue;
  begin
    Result := IntAsJsNumber(Round(GetMasterVolume * 100));
  end;

  function ChakraSetMasterVolume(Args: PJsValue; ArgCount: Word): TJsValue;
  var
    aVolume: Integer;
  begin
    Result := Undefined;

    CheckParams('setMasterVolume', Args, ArgCount, [jsNumber], 1);
    aVolume := JsNumberAsInt(Args^);

    SetMasterVolume(aVolume / 100);
  end;

  function GetDevices(aFlow: TAudioDeviceFlowDirection): TJsValue;
  var
    AudioDevices: TAudioDevices;
    AudioDevice: TAudioDevice;
    Device: TJsValue;
    I, L: Integer;
    DeviceState: String;
  begin
    AudioDevices := GetAudioDevices(aFlow);
    L := Length(AudioDevices);
    Result := CreateArray(L);

    for I := 0 to L - 1 do begin
      AudioDevice := AudioDevices[I];
      Device := CreateObject;

      with AudioDevice do begin
        SetProperty(Device, 'friendlyName', StringAsJsString(FriendlyName));
        SetProperty(Device, 'deviceType', StringAsJsString(DeviceDescription));
        SetProperty(Device, 'flowDirection', StringAsJsString(Flow));

        case State of
          dsActive: DeviceState := 'active';
          dsDisabled: DeviceState := 'disabled';
          dsUnplugged: DeviceState := 'unplugged';
          dsUnknown: DeviceState := 'unknown';
        end;

        SetProperty(Result, 'state', StringAsJsString(DeviceState));
      end;

      SetArrayItem(Result, I, Device);
    end;

  end;

  function ChakraGetAudioDevices(Args: PJsValue; ArgCount: Word): TJsValue;
  var
    Flow: TAudioDeviceFlowDirection;
  begin
    CheckParams('getAudioDevices', Args, ArgCount, [jsNumber], 1);

    try
      Flow := TAudioDeviceFlowDirection(JsNumberAsInt(Args^));
    except
      on E: Exception do
        ThrowError(E.Message, []);
    end;

    Result := GetDevices(Flow);
  end;

  function ChakraInitAudio(Args: PJsValue; ArgCount: Word): TJsValue;
  var
    aDevice: Integer;
    aFrequency: Integer;
  begin
    CheckParams('initAudio', Args, ArgCount, [jsNumber, jsNumber], 2);

    aDevice := JsNumberAsInt(Args^); Inc(Args);
    aFrequency := JsNumberAsInt(Args^);

    Result := BooleanAsJsBoolean(BASS_Init(aDevice, aFrequency, 0, 0, Nil));
  end;

  function ChakraShutdownAudio(Args: PJsValue; ArgCount: Word): TJsValue;
  begin
    BASS_Free;
  end;

  function ChakraGetAudioErrorCode(Args: PJsValue; ArgCount: Word): TJsValue;
  begin
    Result := IntAsJsNumber(BASS_ErrorGetCode);
  end;

  function ChakraOpenFileStream(Args: PJsValue; ArgCount: Word): TJsValue;
  var
    aFileName: String;
  begin
    CheckParams('openFileChannel', Args, ArgCount, [jsString], 1);

    aFileName := JsStringAsString(Args^);
    Writeln(aFileName);
    Result := IntAsJsNumber(BASS_StreamCreateFile(False, PChar(aFileName), 0, 0, BASS_STREAM_AUTOFREE));
  end;

  function ChakraGetChannelState(Args: PJsValue; ArgCount: Word): TJsValue;
  begin
    CheckParams('getChannelState', Args, ArgCount, [jsNumber], 1);
    Result := IntAsJsNumber(BASS_ChannelIsActive(JsNumberAsInt(Args^)));
  end;

  function ChakraGetChannelLength(Args: PJsValue; ArgCount: Word): TJsValue;
  begin
    CheckParams('getChannelPosition', Args, ArgCount, [jsNumber], 1);
    Result := IntAsJsNumber(BASS_ChannelGetLength(JsNUmberAsInt(Args^), BASS_POS_BYTE));
  end;

  function ChakraGetChannelPosition(Args: PJsValue; ArgCount: Word): TJsValue;
  begin
    CheckParams('getChannelPosition', Args, ArgCount, [jsNumber], 1);
    Result := IntAsJsNumber(BASS_ChannelGetPosition(JsNUmberAsInt(Args^), BASS_POS_BYTE));
  end;

  function ChakraSetChannelPosition(Args: PJsValue; ArgCount: Word): TJsValue;
  var
    aChannel, aPosition: Integer;
  begin
    CheckParams('setChannelPosition', Args, ArgCount, [jsNumber, jsNumber], 2);

    aChannel := JsNumberAsInt(Args^); Inc(Args);
    aPosition := JsNumberAsInt(Args^);
    Result := BooleanAsJsBoolean(BASS_ChannelSetPosition(aChannel, aPosition, BASS_POS_BYTE));
  end;

  function ChakraGetChannelVolume(Args: PJsValue; ArgCount: Word): TJsValue;
  var
    aChannel: Integer;
    Volume: Single;
  begin
    CheckParams('getChannelVolume', Args, ArgCount, [jsNumber], 1);
    aChannel := JsNumberAsInt(Args^);

    Result := IntAsJsNumber(-1);

    if BASS_SetDevice(aChannel) then begin
      Volume := BASS_GetVolume;
      Result := IntAsJsNumber(Round(Volume * 100));
    end;
  end;

  function ChakraSetChannelVolume(Args: PJsValue; ArgCount: Word): TJsValue;
  var
    aChannel: Integer;
    aVolume: Single;
  begin
    CheckParams('setChannelVolume', Args, ArgCount, [jsNumber, jsNumber], 2);
    aChannel := JsNumberAsInt(Args^); Inc(Args);

    aVolume := JsNumberAsInt(Args^) / 100;

    Result := BooleanAsJsBoolean(False);

    if BASS_SetDevice(aChannel) then begin
      Result := BooleanAsJsBoolean(BASS_SetVolume(aVolume));
    end;
  end;

  function ChakraGetChannelSpectrum(Args: PJsValue; ArgCount: Word): TJsValue;
  var
    aChannel: Integer;
    aSpectrumType: TAudioSpectrumType;
    aHeight, aWidth: Integer;
  begin
    CheckParams('getChannelSpectrum', Args, ArgCount, [jsNumber, jsNumber, jsNumber, jsNumber], 4);

    aChannel := JsNumberAsInt(Args^); Inc(Args);

    try
      aSpectrumType := TAudioSpectrumType(JsNumberAsInt(Args^));
      Inc(Args);
    except
      on E: Exception do
        ThrowError(E.Message, []);
    end;

    aHeight := JsNumberAsInt(Args^); Inc(Args);
    aWidth := JsNumberAsInt(Args^);

    Result := GetChannelSpectrum(aChannel, aSpectrumType, aHeight, aWidth);
  end;

  function ChakraStartChannel(Args: PJsValue; ArgCount: Word): TJsValue;
  begin
    CheckParams('startChannel', Args, ArgCount, [jsNumber], 1);

    Result := BooleanAsJsBoolean(BASS_ChannelStart(JsNumberAsInt(Args^)));
  end;

  function ChakraPauseChannel(Args: PJsValue; ArgCount: Word): TJsValue;
  begin
    CheckParams('pauseChannel', Args, ArgCount, [jsNumber], 1);

    Result := BooleanAsJsBoolean(BASS_ChannelPause(JsNumberAsInt(Args^)));
  end;

  function ChakraStopChannel(Args: PJsValue; ArgCount: Word): TJsValue;
  begin
    CheckParams('stopChannel', Args, ArgCount, [jsNumber], 1);

    Result := BooleanAsJsBoolean(BASS_ChannelStop(JsNumberAsInt(Args^)));
  end;

  function GetJsValue;
  begin

    Result := CreateObject;

    SetFunction(Result, 'getMasterVolume', ChakraGetMasterVolume);
    SetFunction(Result, 'setMasterVolume', ChakraSetMasterVolume);

    SetFunction(Result, 'initAudio', ChakraInitAudio);
    SetFunction(Result, 'shutdownAudio', ChakraShutdownAudio);
    SetFunction(Result, 'getAudioErrorCode', ChakraGetAudioErrorCode);

    SetFunction(Result, 'openFileStream', ChakraOpenFileStream);

    SetFunction(Result, 'getChannelState', ChakraGetChannelState);

    SetFunction(Result, 'getChannelVolume', ChakraGetChannelVolume);
    SetFunction(Result, 'setChannelVolume', ChakraSetChannelVolume);

    SetFunction(Result, 'getChannelLength', ChakraGetChannelLength);
    SetFunction(Result, 'getChannelPosition', ChakraGetChannelPosition);
    SetFunction(Result, 'setChannelPosition', ChakraSetChannelPosition);

    SetFunction(Result, 'getChannelSpectrum', ChakraGetChannelSpectrum);

    SetFunction(Result, 'startChannel', ChakraStartChannel);
    SetFunction(Result, 'pauseChannel', ChakraPauseChannel);
    SetFunction(Result, 'stopChannel', ChakraStopChannel);

    SetFunction(Result, 'getAudioDevices', ChakraGetAudioDevices);

  end;

end.
