# ffmpeg

1. 查看ffmepg支持的视频文件格式：ffmpeg -formats
	
	* 第一列：多媒体文件的封装格式的Demuxing、Muxing的支持
	* 第二列：多媒体文件格式
	* 第三列：文件格式的详细说明
	
2. 查看ffmepg支持编码、解码
	```
	ffmpeg -codecs
	ffmpeg -decoders           
	ffmpeg -encoders       
	```

3. 查看支持滤镜： ffmpeg -filters


4. 查看flv封装器的参数支持 ffmpeg -h muxer=flv

5. 查看flv解封装器的参数支持 ffmpeg -h demuxer=flv

6. 查看H.264(AVC)的编码参数支持： ffmpeg -h encoder=h264

7. 查看H.264(AVC)的解码参数支持： ffmpeg -h decoder=h264

8. 查看colorkey滤镜的参数支持： ffmpeg -h filter=colorkey


## 案例1：
1. 将MP4转换为flv
	```
	ffmpeg -i a.mp4 -vcodec copy -acodec copy out.flv
	```
	* vcodec copy： 视频处理方式，复制
	* acodec copy: 音频处理方式，复制

2. 只抽取音频：
	```
	ffmpeg -i mov.ts -acodec copy -vn mov.mp4
	```
3. 只抽取视频：
	```
	ffmpeg -i mov.ts -an -vcodec copy mov.mp4
	```

4. 提取视频的yuv
```
ffmpeg -i mov.mp4 -an -c:v rawvideo -fix_fmt yuv420p out.yuv
```
* an：禁用音频


5. 提取音频的pcm
```
ffmpeg -i mov.mp4 -vn -ar 44100 -ac 2 -f s16le mov.pcm
```
* vn：禁用视频
* ar: 采样率
* ac 2： 双声道

6. amr转MP3
```
ffmpeg -i v_helmetVoice.amr v_helmetVoice.mp3 
```

7. mp3转amr：
```
ffmpeg -i v_helmetVoice.mp3 -ar 8000 -ac 1 2.amr
```

ffmpeg -i v_helmetVoice.mp3 -ar 8000 1.amr -ar 8000

ffmpeg -i music.mp3 -ar 8000 -ac 1 2.amr

ffmpeg -i v_helmetVoice.mp3 -ar 8000 -ac 1 2.amr






1. 推送视频流rtmp
```
ffmpeg -re -i F:\video\test.mp4 -vcodec libx264 -acodec aac -strict -2 -f flv rtmp://114.116.49.111:1935/live/864082010106865
```



E:\Tools\ffmpeg-20191229-e20c6d9-win64-static\bin\ffmpeg -re -i F:\video\test.mp4 -vcodec libx264 -acodec aac -strict -2 -f flv rtmp://114.116.49.111:1935/live/864082010106865


ffmpeg -i  https://cn8.qxreader.com/hls/20200128/9b15b6798ef65eaa61d05489b905c51e/1580204442/index.m3u8 G:\视频\冰雪奇缘.mp4

ffmpeg -y -i a.txt -vcodec copy -acodec copy -vbsf h264_mp4toannexb G:\视频\冰雪奇缘2.mp4

ffmpeg -y -i a.txt -vcodec copy -acodec copy -vbsf h264_mp4toannexb G:\视频\冰雪奇缘2.mp4

ffmpeg -i a.txt G:\视频\冰雪奇缘2.mp4



ffmpeg -y -f concat -i a.txt -crf 18 -ar 48000 -vcodec libx264 -c:a aac -r 25 -g 25 -keyint_min 25 -strict -2 G:\视频\冰雪奇缘2.mp4






