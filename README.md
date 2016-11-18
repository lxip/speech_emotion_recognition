# cs352_audio
audio emotion classification using GA for feature optimization

[Berlin Database ](http://emodb.bilderbar.info/index-1280.html)[(related paper)](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.130.8506&rep=rep1&type=pdf)

Index  | Letter | Emotion(eng) | No. of files (per gender)
------ | ------ | ------------ | -------------------------
1 | N | neutral | 79  (39M40F)
2 | W | anger   | 127 (83M44F)
3 | L | boredom | 81  (35M36F)
4 | E | disgust | 46  (11M35F)
5 | A | fear    | 69  (36M33F)
6 | F | happiness | 71  (27M44F)
7 | T | sadness | 62  (25M37F)

NOTE: Make sure to run the setup.m script first to make all directories visible
NOTE: The compareEmo* scripts require MATLAB version R2014b or later (for histcounts fct)
