# Must Declare variables
Opt('MustDeclareVars', 1)

TCPStartup();

Local $ms = TCPListen(@IPAddress1, 4040, 100)
If $ms = -1 Then
   MsgBox(1024, "Bluh", "Cannot open socket")
   Exit
EndIf

While 1
   Local $cs = TCPAccept($ms)
   Local $exit = 0;
   If $cs >= 0 Then
	  $recv = TCPRecv($cs, 2048)
	  If @error Then ExitLoop
	  $route = Router(BinaryToString($recv, 4))
	  Switch $route
		 Case "hello"
			TCPSend($cs, StringToBinary(MakeHttp("Hello, World!"), 4))
		 Case "who"
			TCPSend($cs, StringToBinary(MakeHttp("RUN!"), 4))
		 Case "bye"
			TCPSend($cs, StringToBinary(MakeHttp("Goodbye."), 4))
			$exit = 1
		 Case Else
			TCPSend($cs, StringToBinary(MakeHttp("hello, run, bye"), 4))
	  EndSwitch
	  If @error Then ExitLoop
	  TCPCloseSocket($cs)
	  If $exit == 1 Then ExitLoop
   EndIf
WEnd

Func Router($header)
   If StringUpper(StringLeft($header, 3)) <> "GET" Then Return MakeHttp("Not a GET request.")
   Local $parts = StringSplit($header, " ", 2)
   Local $path = StringLower(StringTrimLeft($parts[1], 1))
   Return $path
EndFunc

Func MakeHttp($content)
   Local $res = ""
   $res &= "HTTP/1.0 200 OK" & @CRLF
   $res &= "Server: AutoIT Test" & @CRLF
   $res &= "Content-Length: " & StringLen($content) & @CRLF
   $res &= "Content-Type: text/plain; charset=UTF-8" & @CRLF & @CRLF
   $res &= $content
   Return $res;
EndFunc