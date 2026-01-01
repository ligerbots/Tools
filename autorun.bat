@echo off
rem detect if this is an admin session and change the text color to bright green
rem
rem The whoami method is more direct, but whoami /groups is very slow
rem whoami /groups | findstr /c:" S-1-5-32-544 " | findstr /c:" Enabled group" && color 0a
rem so we use net session and see if it failed over not
net session >nul 2>&1 && color 0a

