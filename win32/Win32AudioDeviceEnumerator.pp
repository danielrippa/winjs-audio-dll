unit Win32AudioDeviceEnumerator;

{$mode delphi}

interface

  uses
    Windows, ActiveX;

  const
    CLASS_IMMDeviceEnumerator: TGUID = '{BCDE0395-E52F-467C-8E3D-C4579291692E}';

  const
    DEVICE_STATE_ACTIVE     = $00000001;
    DEVICE_STATE_DISABLED   = $00000002;
  //  DEVICE_STATE_NOTPRESENT = $00000004;
    DEVICE_STATE_UNPLUGGED  = $00000008;
  //  DEVICE_STATEMASK_ALL    = $0000000F;

  {$MINENUMSIZE 4}
  type
    EDataFlow = (
      eRender,
      eCapture,
      eAll,
      EDataFlow_enum_count);

    ERole = (
      eConsole,
      eMultimedia,
      eCommunications,
      ERole_enum_count);

    TPropertyKey = record
      fmtid: TGUID;
      pid: DWORD;
    end;

    IMMNotificationClient = interface(IUnknown)
      ['{7991EEC9-7E89-4D85-8390-6C703CEC60C0}']
      function OnDeviceStateChanged(pwstrDeviceId: LPWSTR;
        dwNewState: DWORD): HRESULT; stdcall;
      function OnDeviceAdded(pwstrDeviceId: LPWSTR): HRESULT; stdcall;
      function OnDeviceRemoved(pwstrDeviceId: LPWSTR): HRESULT; stdcall;
      function OnDefaultDeviceChanged(flow: EDataFlow; role: ERole;
        pwstrDefaultDeviceId: LPWSTR): HRESULT; stdcall;
      function OnPropertyValueChanged(pwstrDeviceId: LPWSTR;
        const key: TPropertyKey): HRESULT; stdcall;
    end;

    IPropertyStore = interface(IUnknown)
      function GetCount(out cProps: DWORD): HRESULT; stdcall;
      function GetAt(iProp: DWORD; out key: TPropertyKey): HRESULT; stdcall;
      function GetValue(const key: TPropertyKey;
        out value: TPropVariant): HRESULT; stdcall;
    end;

    IMMDevice = interface(IUnknown)
      ['{D666063F-1587-4E43-81F1-B948E807363F}']
      function Activate(const iid: TGUID; dwClsCtx: DWORD;
        pActivationParams: PPropVariant;
        out EndpointVolume: IUnknown): HRESULT; stdcall;
      function OpenPropertyStore(stgmAccess: DWORD;
        out Properties: IPropertyStore): HRESULT; stdcall;
      function GetId(out strId: LPWSTR): HRESULT; stdcall;
      function GetState(out State: DWORD): HRESULT; stdcall;
    end;

    IMMDeviceCollection = interface(IUnknown)
      ['{0BD7A1BE-7A1A-44DB-8397-CC5392387B5E}']
      function GetCount(out cDevices: UINT): HRESULT; stdcall;
      function Item(nDevice: UINT; out Device: IMMDevice): HRESULT; stdcall;
    end;

    IMMDeviceEnumerator = interface(IUnknown)
      ['{A95664D2-9614-4F35-A746-DE8DB63617E6}']
      function EnumAudioEndpoints(dataFlow: EDataFlow;
        dwStateMask: DWORD; out Devices: IMMDeviceCollection): HRESULT; stdcall;
      function GetDefaultAudioEndpoint(EDF: EDataFlow; role: ERole;
        out EndPoint: IMMDevice): HRESULT; stdcall;
      function GetDevice(pwstrId: LPWSTR; out EndPoint: IMMDevice): HRESULT; stdcall;
      function RegisterEndpointNotificationCallback(
        const Client: IMMNotificationClient): HRESULT; stdcall;
      function UnregisterEndpointNotificationCallback(
        const Client: IMMNotificationClient): HRESULT; stdcall;
    end;

  function GetAudioDeviceEnumerator: IMMDeviceEnumerator;

implementation

  uses
    ComObj;

  function GetAudioDeviceEnumerator;
  begin
    Result := CreateComObject(CLASS_IMMDeviceEnumerator) as IMMDeviceEnumerator;
  end;

end.
