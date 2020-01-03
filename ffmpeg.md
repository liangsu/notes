# ffmpeg

1. 推送视频流rtmp
```
ffmpeg -re -i F:\video\test.mp4 -vcodec libx264 -acodec aac -strict -2 -f flv rtmp://114.116.49.111:1935/live/864082010106865
```



E:\Tools\ffmpeg-20191229-e20c6d9-win64-static\bin\ffmpeg -re -i F:\video\test.mp4 -vcodec libx264 -acodec aac -strict -2 -f flv rtmp://114.116.49.111:1935/live/864082010106865