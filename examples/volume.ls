
  audio = winjs.load-library 'WinjsAudio.dll'

  if process.args.length > 3

    volume = parse-int process.args.3

    audio.set-master-volume volume

  else

    process.io.stdout audio.get-master-volume!

