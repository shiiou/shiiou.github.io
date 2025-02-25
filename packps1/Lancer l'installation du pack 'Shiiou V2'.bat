@echo off
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -UseBasicParsing 'https://shiiou.github.io/packps1/shiiouv2.ps1' | Invoke-Expression}"
pause
exit /b
