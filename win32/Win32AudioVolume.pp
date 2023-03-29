unit Win32AudioVolume;

{$mode delphi}

interface

  const

    IID_IAudioEndpointVolume : TGUID = '{5CDF2C82-841E-4546-9722-0CF74078229A}';

  type

    IAudioEndpointVolumeCallback = interface(IUnknown)
      ['{657804FA-D6AD-4496-8A60-352752AF4F89}']
    end;

    IAudioEndpointVolume = interface(IUnknown)
      ['{5CDF2C82-841E-4546-9722-0CF74078229A}']

      function RegisterControlChangeNotify(AudioEndPtVol: IAudioEndpointVolumeCallback): Integer; stdcall;
      function UnregisterControlChangeNotify(AudioEndPtVol: IAudioEndpointVolumeCallback): Integer; stdcall;
      function GetChannelCount(out PInteger): Integer; stdcall;
      function SetMasterVolumeLevel(fLevelDB: single; pguidEventContext: PGUID): Integer; stdcall;
      function SetMasterVolumeLevelScalar(fLevelDB: single; pguidEventContext: PGUID): Integer; stdcall;
      function GetMasterVolumeLevel(out fLevelDB: single): Integer; stdcall;
      function GetMasterVolumeLevelScaler(out fLevelDB: single): Integer; stdcall;
      function SetChannelVolumeLevel(nChannel: Integer; fLevelDB: double; pguidEventContext: PGUID): Integer; stdcall;
      function SetChannelVolumeLevelScalar(nChannel: Integer; fLevelDB: double; pguidEventContext: PGUID): Integer; stdcall;
      function GetChannelVolumeLevel(nChannel: Integer; out fLevelDB: double): Integer; stdcall;
      function GetChannelVolumeLevelScalar(nChannel: Integer; out fLevel: double): Integer; stdcall;
      function SetMute(bMute: Boolean; pguidEventContext: PGUID): Integer; stdcall;
      function GetMute(out bMute: Boolean): Integer; stdcall;
      function GetVolumeStepInfo(pnStep: Integer; out pnStepCount: Integer): Integer; stdcall;
      function VolumeStepUp(pguidEventContext: PGUID): Integer; stdcall;
      function VolumeStepDown(pguidEventContext: PGUID): Integer; stdcall;
      function QueryHardwareSupport(out pdwHardwareSupportMask): Integer; stdcall;
      function GetVolumeRange(out pflVolumeMindB: double; out pflVolumeMaxdB: double; out pflVolumeIncrementdB: double): Integer; stdcall;
    end;

  function GetMasterVolume: Single;
  procedure SetMasterVolume(aVolume: Single);

implementation

  uses
    Win32AudioDeviceEnumerator, Windows, ActiveX;

  function GetDefaultAudioEndpoint: IMMDevice;
  var
    Enumerator: IMMDeviceEnumerator;
  begin
    Enumerator := GetAudioDeviceEnumerator;
    Enumerator.GetDefaultAudioEndpoint(eRender, eConsole, Result);
  end;

  function GetEndpointVolume: IAudioEndpointVolume;
  var
    Endpoint: IUnknown;
  begin
    Result := Nil;
    GetDefaultAudioEndpoint.Activate(IID_IAudioEndpointVolume, CLSCTX_INPROC_SERVER, Nil, Endpoint);
    Result := Endpoint as IAudioEndpointVolume;
  end;

  function GetMasterVolume;
  begin
    GetEndpointVolume.GetMasterVolumeLevelScaler(Result);
  end;

  procedure SetMasterVolume;
  begin
    GetEndpointVolume.SetMasterVolumeLevelScalar(aVolume, Nil);
  end;

end.