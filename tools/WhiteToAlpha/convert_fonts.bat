javac WhiteAsAlpha.java
if errorlevel 1 goto error

java -ea -server WhiteAsAlpha consola_9x14.png
java -ea -server WhiteAsAlpha consola_11x17.png
java -ea -server WhiteAsAlpha consola_13x20.png
java -ea -server WhiteAsAlpha consola_15x24.png
java -ea -server WhiteAsAlpha consola_17x27.png
java -ea -server WhiteAsAlpha consola_19x30.png
java -ea -server WhiteAsAlpha consola_21x33.png

copy consola_9x14.png ..\..\data\fonts
copy consola_11x17.png ..\..\data\fonts
copy consola_13x20.png ..\..\data\fonts
copy consola_15x24.png ..\..\data\fonts
copy consola_17x27.png ..\..\data\fonts
copy consola_19x30.png ..\..\data\fonts
copy consola_21x33.png ..\..\data\fonts

goto noproblem

:error
pause


:noproblem 
pause
