set O=c:\openssl\bin\openssl.exe
set CA=root-ca
set SUBCA=sub-ca

rmdir /S /Q %CA%
mkdir %CA%
cd %CA%
curl -k https://raw.githubusercontent.com/moonman81/ca-templates/master/private-ca/%CA%.conf --output %CA%.conf
mkdir certs db private
REM chmod 700 private
copy /b NUL db\index
%O% rand -hex 16  > db\serial
echo 1001 > db\crlnumber
cd ..

cd %CA%
%O% req -new -config %CA%.conf -out %CA%.csr -keyout private\%CA%.key
%O% ca -selfsign -config %CA%.conf -in %CA%.csr -out %CA%.crt -extensions ca_ext
%O% ca -gencrl -config %CA%.conf -out %CA%.crl
%O% req -new -newkey rsa:2048 -subj "/C=GB/O=Example/CN=OCSP Root Responder" -keyout private\%CA%-ocsp.key -out %CA%-ocsp.csr
%O% openssl ca -config %CA%.conf -in %CA%-ocsp.csr -out %CA%-ocsp.crt -extensions ocsp_ext -days 30
REM %O% ocsp -port 9080 -index db/index -rsigner %CA%-ocsp.crt -rkey private\%CA%-ocsp.key -CA %CA%.crt -text
REM %O% ocsp -issuer %CA%.crt -CAfile %CA%.crt -cert %CA%-ocsp.crt -url http://127.0.0.1:9080
cd ..

rmdir /S /Q %SUBCA%
mkdir %SUBCA%
cd %SUBCA%
curl -k https://raw.githubusercontent.com/moonman81/ca-templates/master/%SUBCA%.conf --output %SUBCA%.conf
mkdir certs db private
REM chmod 700 private
copy /b NUL db\index
%O% rand -hex 16  > db\serial
echo 1001 > db\crlnumber
cd ..

cd %SUBCA%
%O% req -new -config %SUBCA%.conf -out %SUBCA%.csr -keyout private/%SUBCA%.key
cd ..
cd %CA%
%O% ca -config %CA%.conf -in ..\%SUBCA%\%SUBCA%.csr -out ..\%SUBCA%\%SUBCA%.crt -extensions sub_ca_ext
cd ..
cd %SUBCA%
%O% ca -gencrl -config %SUBCA%.conf -out %SUBCA%.crl
%O% req -new -newkey rsa:2048 -subj "/C=GB/O=Example/CN=OCSP Root Responder" -keyout private\%SUBCA%-ocsp.key -out %SUBCA%-ocsp.csr
%O% openssl ca -config %SUBCA%.conf -in %SUBCA%-ocsp.csr -out %SUBCA%-ocsp.crt -extensions ocsp_ext -days 30
REM %O% ocsp -port 9080 -index db/index -rsigner %SUBCA%-ocsp.crt -rkey private\%SUBCA%-ocsp.key -CA %SUBCA%.crt -text
REM %O% ocsp -issuer %SUBCA%.crt -CAfile %SUBCA%.crt -cert %SUBCA%-ocsp.crt -url http://127.0.0.1:9080
REM %O% ca -config %SUBCA%.conf -in server.csr -out server.crt -extensions server_ext
REM %O% ca -config %SUBCA%.conf -in client.csr -out client.crt -extensions client_ext
cd ..


