unit ChakraAudio;

{$mode delphi}

interface

  uses
    ChakraTypes;

  function GetJsValue: TJsValue;

implementation

  uses
    Chakra, ChakraUtils, Win32AudioDevices, Win32AudioVolume, ChakraErr, SysUtils;

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

  function GetJsValue;
  begin

    Result := CreateObject;

    SetFunction(Result, 'getMasterVolume', ChakraGetMasterVolume);
    SetFunction(Result, 'setMasterVolume', ChakraSetMasterVolume);

    SetFunction(Result, 'getAudioDevices', ChakraGetAudioDevices);

  end;

end.
