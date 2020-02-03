# ffmpeg

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