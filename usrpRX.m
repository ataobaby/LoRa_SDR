clear,clc;

%% 配置参数
SF = 10;  %扩频因子
BW = 500e3; %带宽
fc = 915e6; %发射频段
Power = 14; %功率
message = "1" ;
Fs = 5e6 ;
tx = sdrtx('Pluto','RadioID','usb:0','CenterFrequency',fc,...
    'BasebandSampleRate',Fs,...
    'SamplesPerFrame',2e6,'Gain',0);
rx = sdrrx('Pluto','RadioID','usb:0','CenterFrequency',fc,...
    'BasebandSampleRate',Fs,...
    'OutputDataType','double',...
    'SamplesPerFrame',2e6,'Gain',60);    
%% Transmit Signal
signalIQ = LoRa_Tx(message,BW,SF,Power,Fs,0);
upChirp = signalIQ(1:10240);
Tdata = signalIQ;
Tdata=[zeros(length(Tdata),1);Tdata];

%% 发射流程
while 1
    k =  0;
    while 1
        k = k+1;
        Rdata = rx();
        signalIndex = signalCapture(Rdata,upChirp,8,0);
        if signalIndex ~= -1 
           disp(char(LoRa_Rx(Rdata(signalIndex:min([signalIndex+309759,2e6])),BW,SF,2,Fs,0))) ;
           break;
        end
    end
    disp('pong');
    tx(Tdata);
end
release(tx);
release(rx);