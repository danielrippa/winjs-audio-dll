# WinjsAudio.dll

```
  
  get-js-value ->
    
    get-audio-devices: -> string
    
    get-master-volume: -> number
    set-master-volume: (volume: number) -> void
    
    init-audio: (device: number, frequency: number) -> boolean
    shutdown-audio: -> void
    
    get-audio-error-code: -> number
    
    open-file-stream: (filename: string) -> number
    
    get-channel-state: (channel: number) -> number
    
    get-channel-length: (channel: number) -> number
    
    get-channel-position: (channel: number) -> number
    set-channel-position: (channel: number, position: number) -> boolean
    
    get-channel-volume: (channel: number) -> number
    set-channel-volume: (channel: number, volume: number) -> boolean
    
    get-channel-spectrum: (channel: number, spectrum-type: number, spectrum-height: number, spectrum-width: number) -> {}
    
    start-channel: (channel: number) -> boolean
    pause-channel: (channel: number) -> boolean
    stop-channel:  (channel: number) -> boolean
    
  
```
