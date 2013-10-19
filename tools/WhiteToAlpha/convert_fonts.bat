javac WhiteAsAlpha.java
if errorlevel 1 goto error

java -ea -server WhiteAsAlpha consola_9x14.png
java -ea -server WhiteAsAlpha consola_11x17.png
java -ea -server WhiteAsAlpha consola_13x20.png
java -ea -server WhiteAsAlpha consola_15x24.png
java -ea -server WhiteAsAlpha consola_17x27.png
java -ea -server WhiteAsAlpha consola_19x30.png
java -ea -server WhiteAsAlpha consola_21x33.png

goto noproblem

:error
pause


:noproblem 
pause
