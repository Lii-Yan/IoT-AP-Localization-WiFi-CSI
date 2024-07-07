@echo off
cd /d "%~dp0"
call activate torch
start /B python main.py
exit
