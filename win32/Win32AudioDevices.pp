unit Win32AudioDevices;

{$mode delphi}

interface

  type

    TAudioDeviceState = (dsUnknown, dsActive, dsDisabled, dsUnplugged);
    TAudioDeviceStates = Set of TAudioDeviceState;
    TAudioDeviceFlowDirection = (fdRender, fdCapture, fdBoth);

    TAudioDevice = record
      FriendlyName: String;
      State: TAudioDeviceState;
      DeviceDescription: String;
      ID: String;
      Flow: String;
    end;

    TAudioDevices = Array of TAudioDevice;

  function GetAudioDevices(aFlowDirection: TAudioDeviceFlowDirection): TAudioDevices;

implementation

  uses
    Win32AudioDeviceEnumerator, ActiveX, ComObj, CTypes, StrUtils;

  const

    IID_IMMEndpoint: TGUID = '{1BE09788-6894-4089-8586-9A2A6C265AC5}';

  type

    IMMEndpoint = interface(IUnknown)
      ['{1BE09788-6894-4089-8586-9A2A6C265AC5}']
      function GetDataFlow(out pDataFlow: eDataFlow): HRESULT; stdcall;
    end;

  function PropVariantClear(var PropVar: TPropVariant): HRESULT; stdcall; external 'ole32.dll';

  procedure PropVariantInit(out PropVar: TPropVariant); inline;
  begin
    FillByte(PropVar, SizeOf(PropVar), 0);
  end;

  function GetFriendlyName(aValue: String): String;
  var
    StartPos, EndPos: Integer;
  begin
    StartPos := Pos('(', aValue);
    Result := Copy(aValue, StartPos + 1);

    EndPos := RPos(')', Result);
    Result := Copy(Result, 0, EndPos - 1);
  end;

  function AudioDeviceFromMMDevice(aDevice: IMMDevice): TAudioDevice;
  const
    PKEY_Device_DeviceDesc: TPropertyKey = (fmtid: '{a45c254e-df1c-4efd-8020-67d146a850e0}'; pid: 2);
    PKEY_Device_FriendlyName: TPropertyKey = (fmtid:'{A45C254E-DF1C-4EFD-8020-67D146A850E0}'; pid:14);
  var
    DeviceState: DWord;
    DeviceID: PWideChar;
    DeviceString: TPropVariant;
    DataFlow: EDataFlow;
    StringProperty: UnicodeString;
    Properties: IPropertyStore;
    Endpoint: IMMEndpoint ;
  begin

    with aDevice do begin

      GetState(DeviceState);
      case DeviceState of
        DEVICE_STATE_ACTIVE: Result.State := dsActive;
        DEVICE_STATE_DISABLED: Result.State := dsDisabled;
        DEVICE_STATE_UNPLUGGED: Result.State := dsUnplugged;

        else
          Result.State := dsUnknown;
      end;

      OpenPropertyStore(STGM_READ, Properties);

      GetId(DeviceID);
      Result.ID := DeviceID;
      CoTaskMemFree(DeviceID);

      PropVariantInit(DeviceString);
      Properties.GetValue(PKEY_Device_FriendlyName, DeviceString);
      Result.FriendlyName := GetFriendlyName(DeviceString.pwszVal);
      PropVariantClear(DeviceString);

      PropVariantInit(DeviceString);
      Properties.GetValue(PKEY_Device_DeviceDesc, DeviceString);
      Result.DeviceDescription := DeviceString.pwszVal;
      PropVariantClear(DeviceString);

      aDevice.QueryInterface(IID_IMMEndpoint, Endpoint);

      Endpoint.GetDataFlow(DataFlow);

      case DataFlow of
        eRender: Result.Flow := 'Render';
        eCapture: Result.Flow := 'Capture';
      end;

      Properties := Nil;

    end;

  end;

  function GetAudioDevices;
  var
    Enumerator: IMMDeviceEnumerator;
    Collection: IMMDeviceCollection;
    DataFlow: EDataFlow;
    Device: IMMDevice;
    DeviceCount: CUInt;
    I: Integer;
  begin

    case aFlowDirection of
      fdRender: DataFlow := eRender;
      fdCapture: DataFlow := eCapture;
      fdBoth: DataFlow := eAll;
    end;

    Enumerator := GetAudioDeviceEnumerator;
    Enumerator.EnumAudioEndpoints(DataFlow, DEVICE_STATE_ACTIVE or DEVICE_STATE_DISABLED or DEVICE_STATE_UNPLUGGED, Collection);

    Collection.GetCount(DeviceCount);
    SetLength(Result, DeviceCount);

    for I := 0 to DeviceCount -1 do begin
      Collection.Item(I, Device);
      Result[I] := AudioDeviceFromMMDevice(Device);
    end;
  end;

end.