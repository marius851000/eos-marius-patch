#ffmpeg -i BGM_DLC_024.dspadpcm.mp3 -ac 1 -ar 44100 -sample_fmt s16 rom/data/SOUND/BGM/streamed_1.wav
#ffmpeg -i audiocheck.net_whitenoise.wav -ac 1 -ar 44100 -sample_fmt s16 rom/data/SOUND/BGM/streamed_1.wav
#ffmpeg -f lavfi -i "sine=frequency=1000:duration=30" -ac 1 -ar 44100 -sample_fmt s16 rom/data/SOUND/BGM/streamed_1.wav
#ffmpeg -i BGM_DUN_09.dspadpcm.mp3 -to 5 -ac 1 -ar 44100 -sample_fmt s16 rom/data/SOUND/BGM/streamed_1.wav
#TODO: maybe s16le is more appropriate
#ffmpeg -i ./Heaven1.ogg -ac 1 -ar 44100 -sample_fmt s16 -f wav rom/data/SOUND/BGM/streamed_1.wav
#ffmpeg -i ./Heaven0.ogg -ac 1 -ar 44100 -sample_fmt s16 -f wav rom/data/SOUND/BGM/streamed_1.was
#ffmpeg -i ./Inst.ogg -i Voices.ogg -filter_complex amerge=inputs=2 -ac 1 -ar 44100 -sample_fmt s16 -f wav rom/data/SOUND/BGM/streamed_1.wav

#ffmpeg -i "Vylet Pony - Way of the Dodo [2579117276].mp3" -ac 1 -ar 44100 -sample_fmt s16 -f wav rom/data/SOUND/BGM/streamed_1.wav
#ffmpeg -i "Heaven1.ogg" -to 5 -ac 1 -ar 44100 -sample_fmt s16 -f wav test_in/A8.wav
cp --reflink=auto "village_trans.wav" "rom/data/SOUND/BGM/streamed_1.wav"
#ffmpeg -i "Heaven1.ogg" -ac 1 -ar 44100 -sample_fmt s16 -f wav "rom/data/SOUND/BGM/streamed_2.wav"
cp --reflink=auto "Ball1ch.wav" "rom/data/SOUND/BGM/streamed_2.wav"
ffmpeg -i "Enchanted Festival/Enchanted Festival Loop.wav" -ac 1 -ar 44100 -sample_fmt s16 -f wav "rom/data/SOUND/BGM/streamed_3.wav"