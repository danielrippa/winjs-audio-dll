
  { get-audio-devices } = winjs.load-library 'WinjsAudio.dll'

  flow-direction =
    render: 0
    capture: 1
    both: 2

  for device, index in get-audio-devices flow-direction.both

    if index is 0
      for k of device => process.io.stdout " #k |"
      process.io.stdout '\n\n'

    for ,v of device => process.io.stdout " #v |"
    process.io.stdout '\n'
