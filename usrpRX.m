clear,clc;

%% 配置参数
SF = 10;  %扩频因子
BW = 500e3; %带宽
fc = 915e6; %发射频段
Power = 14; %功率

Fs = 5e6 ;
tx = sdrtx('Pluto','RadioID','usb:0','CenterFrequency',fc,...
    'BasebandSampleRate',Fs,...
    'SamplesPerFrame',2e6,'Gain',0);
rx = sdrrx('Pluto','RadioID','usb:0','CenterFrequency',fc,...
    'BasebandSampleRate',Fs,...
    'OutputDataType','double',...
    'GainSource','AGC Fast Attack', ...
    'SamplesPerFrame',2e6,'Gain',60);    
%% Transmit Signal
for num = 1:10
    signalIQ = LoRa_Tx(char(num+47),BW,SF,Power,Fs,0); 
    Tdata(:,num) =[zeros(length(signalIQ ),1);signalIQ ];
end
upChirp = signalIQ(1:10240);
%% 发射流程
SendIndex = 1;
baseBandData = [];
while 1
    k =  0;
    while 1
        k = k+1;
        Rdata = rx();
        signalIndex = signalCapture(Rdata,upChirp,8,0);
        if signalIndex ~= -1 && signalIndex+309759 <= 2e6
            numStr = LoRa_Rx(Rdata(signalIndex:min([signalIndex+309759,2e6])),BW,SF,2,Fs,0);
            if numStr>96 && numStr<107
                disp('ping')
                disp(char(numStr));
                Data = [numStr;Rdata(signalIndex:min([signalIndex+309759,2e6]))];
                SendIndex = numStr - 96;
                baseBandData = [baseBandData,Data];
                break;
            end
        end
    end
    disp('pong');
    tx(Tdata(:,SendIndex));
end
release(tx);
release(rx);