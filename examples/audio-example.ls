
  { init-audio, shutdown-audio, open-file-stream, get-channel-length, start-channel, stop-channel, pause-channel, get-channel-state, get-channel-position } = winjs.load-library 'WinjsAudio.dll'
  { console } = dependency 'Console'
  { console-input } = dependency 'ConsoleInput'
  { new-key-input } = dependency 'KeyInput'
  { key-codes: kc } = dependency 'KeyCodes'

  device = -1
  frequency = 44100

  filename = process.args.3

  length = -1

  channel-state =

    stopped: 0
    playing: 1
    stalled: 2
    paused: 3
    paused-device: 4

  key-command = 'none'

  if init-audio device, frequency

    console.hide-cursor!

    keys = new-key-input console-input

    keys.on-key-released (key-event) ->

      switch key-event.character
        | 'q' => key-command := 'quit'

    try

      stream = open-file-stream filename

      if stream isnt 0

        length = get-channel-length stream

        console.write length
        column = console.column + 1

        start-channel stream

        loop

          stream-state = get-channel-state stream

          break if stream-state isnt channel-state.playing

          console-input.notify!

          if key-command isnt 'none'
            console.writeln key-command

          switch key-command

            | 'quit' => stop-channel stream ; break

          console.column = column
          console.write get-channel-position stream

    finally

      shutdown-audio!
      console.show-cursor!
