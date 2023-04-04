
  { init-audio, shutdown-audio, open-file-stream, get-channel-length, start-channel, stop-channel, pause-channel, get-channel-state, get-channel-spectrum, set-channel-volume, get-channel-volume } = winjs.load-library 'WinjsAudio.dll'
  { console } = dependency 'Console'
  { console-input } = dependency 'ConsoleInput'
  { new-key-input } = dependency 'KeyInput'
  { key-codes: kc } = dependency 'KeyCodes'
  { new-braille-string } = dependency 'BrailleString'

  cursor = row: console.row, column: console.column

  cursor-size = console.cursor-size

  render-channel-spectrum = (spectrum, height, width) ->

    console.goto cursor.row, cursor.column

    for channel in spectrum

      console.writeln ''

      line1 = new-braille-string width
      line2 = new-braille-string width

      for value, index in channel
        if value >= 0 then
          line1.set value, index
        else
          line2.set (value * -1), index

      console.writeln '  ', line1
      console.writeln '  ', line2

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

    console.cursor-size = 1
    console.hide-cursor!

    keys = new-key-input console-input

    keys.on-key-released (key-event) ->

      switch key-event.character
        | 'q' => key-command := 'quit'
        | '+' => key-command := 'volup'
        | '-' => key-command := 'voldn'

    try

      stream = open-file-stream filename

      if stream isnt 0

        length = get-channel-length stream

        start-channel stream

        loop

          stream-state = get-channel-state stream

          break if stream-state isnt channel-state.playing

          console-input.notify!

          if key-command isnt 'none'
            console.writeln key-command

          switch key-command

            | 'quit' => stop-channel stream ; break

            | 'volup' =>

              volume = get-channel-volume stream
              set-channel-volume = volume + (volume * 0.1)

            | 'voldn' =>

              volume = get-channel-volume stream
              set-channel-volume = volume - (volume * 0.1)

          console.goto cursor.row, cursor.column

          height = 4 ; width = 10

          render-channel-spectrum (get-channel-spectrum stream, 0, height, width), height, width

    finally

      shutdown-audio!
      console.show-cursor!
      console.cursor-size = cursor-size